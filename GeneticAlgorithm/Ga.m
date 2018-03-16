function Ga
   %GA Genetic Algorithm
   %
   % See also GA>OPTIMIZE, GA>MAXIMIZE, GA>MINIMIZE, GA>DEFAULTCONFIG,
   % GA>SHOWHISTORY.
  global GA;
  
  
  GA.optimize = @optimize;
  GA.maximize = @maximize;
  GA.minimize = @minimize;
  
  GA.defaultConfig = @defaultConfig;
  GA.plot = @plot_;

  GA.showHistory = @showHistory;
end

function result = initialGeneration(N, cities, l)
  [C, ~] = size(cities);
  
  if (l == -1)
	result = zeros(N, C);
    
    for i = 1:N
        result(i, :) = randperm(C);
    end
  else
	error('binary representation is not yet implemented (and probably never will)');
  end
end

function [fitness, real_values_pop] = evalFitnessAndPop(population, fn, decode_fn)
  global UTILS;
  
  real_values_pop = decode_fn(population);
  fitness = UTILS.evalFn(fn, real_values_pop);
end

function result = crossover(mating_pool, crossover_fn, Pc)
  
  %% Modify mating pool to have an array of [i, j] (two individuals on
  %% the same row), so we do not have to introduce an explicit loop
  %% (usually slower) to compute the crossover of each parent pair.
  var_count = length(mating_pool(1, :));
  mating_pool = reshape(mating_pool', 2 * var_count, [])';

  rand_val = rand(length(mating_pool(:, 1)), 1);
  indices = find(rand_val <= Pc); %% Find which pair will crossover

  go_through_crossover = mating_pool(indices, :);
  unchanged = mating_pool;
  unchanged(indices, :) = [];  %% Remove pairs which are going to crossover.

  if (~isempty(go_through_crossover))
      %% Pair separation
      min_b = 1:var_count; %% The first half (first individual)
      max_b = (var_count+1):(var_count * 2); %% The second half (second individual)

      %% NOTE/TODO?: Instead of separating the variables, we could
      %% concatenated them (shift each by l*i bits and directly apply the
      %% crossover and mutation over the resulting integer) and split them
      %% after everything is done. This could, potentialy, speed up the
      %% computation.
      %% Howewer, octave has a limit of 53 bits (at least, bitset limits
      %% the index to 53), which means we would be limited to 53 /
      %% var_count bits per variable. (var_count = 3 => 17 bits)
      %% (By handling them separately, we do not have _any_ limitation)


      go_through_crossover = crossover_fn(go_through_crossover(:, min_b), go_through_crossover(:, max_b));
  end

  %% Flatten the result to have [i1; i2; ...] again, instead of
  %% [ [i1, i2]; [i3, i4]; ... ]
  result = reshape([unchanged; go_through_crossover]', var_count, [])';
end

%% TODO: See what else besides the fitness can be plotted.
function showHistory(history, iterations)
	%SHOWHISTORY Display figures that summarize the algorithm's steps.

  if (iterations == -1)
	iterations = 1:length(history.iterations);
  end
  
  values = history.iterations(iterations);
  
  figure(2);
  clf;
  hold on;

  best_individual_format = 'g*';
  best_individual_size = 10;

  very_best_iteration = history.very_best.iteration;
  bestFitness = history.very_best.fitness;
  
  %subplot(1, 2, 1);
  %hold on;
  plot(iterations, [values.bestFitness], '-+');
  
  plot(iterations(very_best_iteration), bestFitness, best_individual_format, 'markersize', best_individual_size);
  
  xlabel('Iteration');
  ylabel('Max fitness');
  title('Max fitness by iteration');
end

function result = createRecord(population, fitness, objective_fn, compare_fitness_fn)
  global UTILS;
  
  result.population = population;
  result.fitness = fitness;
  result.objective = UTILS.evalFn(objective_fn, population);

  [bestFitness, index] = compare_fitness_fn(fitness); 
  result.bestIndividual = result.population(index, :);
  result.bestFitness = bestFitness;
end

function result = rankProbabilities(fitness, ranking_fn)
  [~, sorted_indices] = sort(fitness);
  result = ranking_fn(sorted_indices - 1); %% ranks must be in [0, N - 1]
end

function result = fitnessProbabilities(fitness, fitness_change_fn)
  fitness = fitness_change_fn(fitness);
  result = fitness / sum(fitness);
end

function [result, history] = optimize(maximizing, objective_fn, fitness_fn, cities, config)
%OPTIMIZE Maximize or minimize FITNESS_FN whose parameters are defined inside the given
% CONSTRAINTS using the given CONFIG.
% (OBJECTIVE_FN is only used to record the population's value at each
% iteration)
%
% Return the best individual from the last iteration as well as an
% history which contains, for each iteration:
% - the population (real values) and its fitness
% - the best individual its fitness
% - the best overall individual (very_best): its value, fitness and the
%   first iteration it appeared in.
%
% [RESULT, HISTORY] = OPTIMIZE(MAXIMIZING, OBJECTIVE_FN, FITNESS_FN, CONSTRAINTS, CONFIG)
%
% See also GA>MAXIMIZING, GA>MINIMIZING.
  
  global UTILS;
  global RANKING;
  global FITNESS_CHANGE;
  global REPLACEMENT;

  %% TODO: Parameter check and default value.
  
  %% TODO: Make sure only binary crossover functions can be used if
  %% l >= 1.
  %% Same for arithmetic functions and l == -1.
  N = config.N;
  %l = config.l;
  l = -1;
  
  G_max = config.G_max;
  
  Pc = config.Pc;
  Pm = config.Pm;

  fitness_change_fn = config.fitness_change_fn;
  selection_fn = config.selection_fn;
  crossover_fn = config.crossover_fn;
  mutation_fn = config.mutation_fn;
  stop_criteria_fn = config.stop_criteria_fn;
  clamp_fn = config.clamp_fn;

  get_probabilities = @fitnessProbabilities;
  probabilities_fn = fitness_change_fn;

  decode_fn = UTILS.decode(l);

  if (maximizing)
	compare_fitness_fn = @max;
  else
	compare_fitness_fn = @min;
  end

  tic;

  dim = size(cities);
  var_count = dim(1);
  population = initialGeneration(N, cities, l);
  
  children_count = N;

  history = {};
  history.iterations(1:G_max+1) = struct('population', [], 'fitness', [], 'objective', [], 'bestIndividual', [], 'bestFitness', 0);

  last_iteration = G_max + 1;
  old_fitness = [];
  for g = 1:G_max
	%% Evaluation
	[fitness, real_values_pop] = evalFitnessAndPop(population, fitness_fn, decode_fn);

	if (stop_criteria_fn(fitness, old_fitness))
	  last_iteration = g;
	  break
    end

	%% Recording
	history.iterations(g) = createRecord(real_values_pop, fitness, objective_fn, compare_fitness_fn);
    
    %% Just so we never have negative fitness values where it is not expected.
	if (maximizing)
      fitness = offsetFitness(fitness);
	else
	  fitness = fitnessTransfert(fitness);
	end

	%% Selection (based on rank or derived from fitness)
	probabilities = get_probabilities(fitness, probabilities_fn);
	selection = selection_fn(probabilities);
	mating_pool = population(UTILS.shuffle(selection), :);

	%% Crossover
	children = crossover(mating_pool, crossover_fn, Pc);

	%% TODO(@debug) Remove this!
	UTILS.DEBUG.assertIntegrity(children, var_count);

	%% Mutation
	%% Every allele that needs to mutate is 1 at the correponding index
	if (l == -1)
	  mutations = rand(children_count, 1, 1) <= Pm;
	else
	  mutations = rand(children_count, l, var_count) <= Pm;
	end

	population = mutation_fn(children, mutations);

	%% TODO(@debug) Remove this!
	UTILS.DEBUG.assertIntegrity(population, var_count);

	%% NOTE: Currently, clamping the population inside the constraints
	%% is done in each crossover / function that _can_ produce
    %% offsprings outside the bounds.
	%% As this is not a performance issue, it could instead be
	%% centralized here (clamping would be done after crossover and
	%% mutation have taken place).
	%% Since every mutation and crossover functions have been
	%% implemented, it will probably not be done.
	
	old_fitness = fitness;
  end

  [fitness, real_values_pop] = evalFitnessAndPop(population, fitness_fn, decode_fn);

  [~, index_best] = compare_fitness_fn(fitness);
  result = real_values_pop(index_best, :);

  history.iterations(last_iteration) = createRecord(real_values_pop, fitness, objective_fn, compare_fitness_fn);

  %% Remove skipped iterations
  history.iterations(last_iteration+1:end) = [];

  [best_fitness, very_best_index] = compare_fitness_fn([history.iterations.bestFitness]);
  best_iteration = history.iterations(very_best_index);
  history.very_best = struct('value', best_iteration.bestIndividual(1, :), 'fitness', best_fitness, 'iteration', very_best_index);

  toc;
end

function [result, history] = maximize(objective_fn, fitness_fn, constraints, config)
%MAXIMIZE Same as OPTIMIZE(1, OBJECTIVE_FN, FITNESS_FN, CONSTRAINTS, CONFIG)
%
% See also GA>OPTIMIZE, GA>MINIMIZE;
  
  [result, history] = optimize(1, objective_fn, fitness_fn, constraints, config);
end

%% NOTE: Minimizing f(x) is maximizing g(x) = max(f(x)) -f(x)
function [result, history] = minimize(obj_fn, fit_fn, constraints, config)
%MINIMIZE Same as OPTIMIZE(0, OBJECTIVE_FN, FITNESS_FN, CONSTRAINTS, CONFIG)
%
% See also GA>OPTIMIZE, GA>MAXIMIZE;
    [result, history] = optimize(0, obj_fn, fit_fn, constraints, config);
end

function result = fitnessTransfert(fitness)
    result = max(fitness) - fitness;
end

function result = offsetFitness(fitness)
  min_fitness = min(fitness);
  
  if (min_fitness < 0)
      %% In case all individuals have the same fitness
      if (min_fitness == max(fitness))
          result = fitness;
      else
        result = fitness - min(fitness);
      end
  else
	result = fitness;
  end
end

function plot_(cities, show_trail)
    [~, dim] = size(cities);
    
    if (~exist('show_trail', 'var'))
       show_trail = false; 
    end
    
    if (show_trail)
        cities(end+1, :) = cities(1, :);
        style = '+-';
    else
        style = '+';
    end
    
    if (dim == 3)
        plot_fn = @plot3;
    else
        plot_fn = @plot;
    end
    
    plotN_(cities, plot_fn, style);
end


function result = plotN_(val_array, plot_fn, varargin)
    BY_COLUMN = 2; 
    to_var_arg = num2cell(val_array', BY_COLUMN);
    
    result = plot_fn(to_var_arg{:}, varargin{:});
end

function result = defaultConfig
	 %DEFAULTCONFIG Preconfigured genetic algorithm config.
	 %
	 % Fields
	 %  N                  Population count
	 %  G_max              Max iteration count
	 %  l                  Chromosome length, in [1, 53]
	 %  Pc                 Crossover probability
	 %  Pm                 Mutation probability
	 %  ranking_fn         Ranking function
	 %  fitness_change_fn  Fitness change function
	 %  selection_fn       Selection function
	 %  crossover_fn       Crossover function
	 %  mutation_fn        Mutation function
	 %  stop_criteria_fn   Stop criteria function
	 %  clamp_fn           Clamp function, not used with binary values
	 %  
	 % See also Ranking, FitnessChange, Selection, Crossover, Mutation,
	 % StopCriteria, Clamp.
  
  global RANKING;
  global FITNESS_CHANGE;
  global SELECTION;
  global CROSSOVER;
  global MUTATION;
  global STOP_CRITERIA;
  global CLAMP;
  global REPLACEMENT;
  
  result.N = 100;
  result.G_max = 100;
  
  %% @binary
  %% NOTE: For now, binary representation is disabled.
  %% NOTE: 'binary' is just an integer representation (to get to the
  % actual value => v = (i / maxI) * (c(1) - c(0)) + c(0), with c the
  % constaints for this variable)
  %result.l = 12;
  
  result.Pc = 0.5;
  result.Pm = 0.1;

  result.fitness_change_fn = FITNESS_CHANGE.linearScale;
  result.selection_fn = SELECTION.wheel;
  result.crossover_fn = CROSSOVER.partial;
  result.mutation_fn = MUTATION.simpleInverse;
  result.stop_criteria_fn = STOP_CRITERIA.time;
  result.clamp_fn = CLAMP.default;
end
