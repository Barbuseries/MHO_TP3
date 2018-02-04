function Ga
  global GA;
  
  
  GA.maximize = @maximize;
  GA.minimize = @minimize;

  GA.defaultConfig = @defaultConfig;

  GA.showHistory = @showHistory;
end

function result = initialGeneration(N, constraints, l)
  global UTILS;
  
  if (l == -1)
	result = UTILS.randomIn(constraints, N);
  else
	dim = size(constraints);
	var_count = dim(1);

	max_val = 2^l-1;

	result = randi(max_val, N, var_count);
  end
end

function [fitness, real_values_pop] = evalFitnessAndPop(population, fn, decode_fn)
  global UTILS;
  
  real_values_pop = decode_fn(population);
  fitness = UTILS.evalFn(fn, real_values_pop);
end

function result = crossover(mating_pool, crossover_fn, Pc, context)
  %% Modify mating pool to have an array of [i, j], so we do not have
  %% to introduce an explicit loop (usually slower) to compute the
  %% crossover of each parent pair.
  var_count = length(mating_pool(1, :));
  mating_pool = reshape(mating_pool', 2 * var_count, [])';

  rand_val = rand(length(mating_pool(:, 1)), 1);
  indices = find(rand_val <= Pc); %% Find which pair will crossover

  go_through_crossover = mating_pool(indices, :);

  %% Pair separations
  min_b = 1:var_count;
  max_b = (var_count+1):(var_count * 2);

  %% NOTE/TODO?: Instead of separating the variables, we could
  %% concatenated them (shift each by l*i bits and directly apply the
  %% crossover and mutation over the resulting integer) and split them
  %% after everything is done. This could, potentialy, speed up the
  %% computation.
  %% Howewer, octave has a limit of 53 bits (at least, bitset limits
  %% the index to 53), which means we would be limited to 53 /
  %% var_count bits per variable. (var_count = 3 => 17 bits)
  %% (By handling them separately, we do not have _any_ limitation)
  unchanged = mating_pool;
  unchanged(indices, :) = [];  %% Find which pair did _not_ crossover

  go_through_crossover = crossover_fn(go_through_crossover(:, min_b), go_through_crossover(:, max_b), context);

  %% Flatten the result to have [i1; i2; ...] again, instead of
  %% [ [i1, i2]; [i3, i4]; ... ]
  result = reshape([unchanged; go_through_crossover]', var_count, [])';
end

%% TODO: Default value for iterations to be -1.
function showHistory(problem, history, iterations)
  global UTILS;
  
  dim = size(history.iterations(1).bestIndividual);
  var_count = dim(2);

  if (iterations == -1)
	iterations = 1:length(history.iterations);
  end
  
  values = history.iterations(iterations);
  
  figure(1);
  clf;
  hold on;

  best_individual_format = 'g*';
  best_individual_size = 10;

  very_best_iteration = history.very_best.iteration;
  very_best = history.very_best.value;
  maxFitness = history.very_best.fitness;
  
  plot(iterations, [values.maxFitness], '-+');
  
  plot(iterations(very_best_iteration), maxFitness, best_individual_format, 'markersize', best_individual_size);
  
  xlabel('Iteration');
  ylabel('Max fitness');
  title('Max fitness by iteration');

  if (var_count <= 2)
	figure(2);
	clf;
	hold on;
	
	%% [values.bestIndividual] returns a 1D array containing
	%% [x1, y1, ..., x2, y2, ...],so we regroup everthing to get
	%% [[x1, y1, ...]; [x2, y2, ...]; ...]
	best_individuals = reshape([values.bestIndividual], var_count, [])';
	
	objective_fn_format = 'b';
	individuals_format = 'r+';
	
	best_x = best_individuals(:, 1);
    vb_x = very_best(1);

	%% TODO: Show iteration order
	%% TODO: Find my old gradient function and use it here.
	%% TODO: Show population at each iteration
	if (var_count == 1)
	  x = UTILS.linspacea(problem.constraints, 1000);
	  
	  plot(x, problem.objective_fn(x), objective_fn_format);
	  plot(best_x, problem.objective_fn(best_x), individuals_format);

	  plot(vb_x, problem.objective_fn(vb_x), best_individual_format, 'markersize', best_individual_size);
	  ylabel('F(x)');
	else
	  domain = UTILS.linspacea(problem.constraints, 200); %% Less points because N^2...
	  x = domain(1, :);
	  y = domain(2, :);

	  %% TODO(@knowledge): See why we need to transpose xx and yy for
	  %% z to be accurate.
	  [xx, yy] = meshgrid(x, y);
	  z = problem.objective_fn(xx', yy')';
	  mesh(x, y, z);

	  best_y = best_individuals(:, 2);
	  plot3(best_x, best_y, problem.objective_fn(best_x, best_y), individuals_format);

      vb_y = very_best(2);
	  plot3(vb_x, vb_y, problem.objective_fn(vb_x, vb_y), best_individual_format, 'markersize', best_individual_size);

	  ylabel('Best individual y');
	  zlabel('F(x, y)');
	end
	
	xlabel('Best individual x');
	title('Objective function F and best individuals at each iteration');
  else
	disp('Too many variables to plot objective function.');
  end
end

function result = createRecord(population, fitness, objective_fn)
  global UTILS;
  
  result.population = population;
  result.fitness = fitness;
  result.objective = UTILS.evalFn(objective_fn, population);

  [maxFitness, index] = max(fitness); 
  result.bestIndividual = result.population(index, :);
  result.maxFitness = maxFitness;
end

%% Maximize fn whose parameters are defined inside the given
%% constraints.
%% fn must only take one parameter. This parameter contains as many
%% columns as there are constraints. (If three constraints are given,
%% fn receives a parameter with three columns)
%%
%% Return the best individual from the last iteration as well as an
%% history which contains, for each iteration:
%% - the population (real values)
%% - its fitness
%% - the best individual
%% - its fitness
%% and the best overall individual (very_best) along with its value,
%% its fitness and its iteration.
function [result, history] = maximize(objective_fn, fitness_fn, constraints, config)
  global UTILS;
  
  %% TODO: Parameter check and default value.
  
  %% TODO: Make sure only binary crossover functions can be used if
  %% l >= 1.
  %% Same for arithmetic functions and l == -1.
  N = config.N;
  l = config.l;
  
  G_max = config.G_max;
  
  Pc = config.Pc;
  Pm = config.Pm;

  fitness_change_fn = config.fitness_change_fn;
  selection_fn = config.selection_fn;
  crossover_fn = config.crossover_fn;
  mutation_fn = config.mutation_fn;

  decode_fn = UTILS.decode(constraints, l);

  tic;

  dim = size(constraints);
  var_count = dim(1);
  population = initialGeneration(N, constraints, l);
  
  if (l == -1)
	context = struct('constraints', constraints, 'G_max', G_max, 'iteration', 0);
  else
	context = l;
  end

  history = {};
  history.iterations(1:G_max+1) = struct('population', [], 'fitness', [], 'objective', [], 'bestIndividual', [], 'maxFitness', 0);

  for g = 1:G_max
	if (l == -1)
	  context.iteration = g;
	end
	
	%% Evaluation
	[fitness, real_values_pop] = evalFitnessAndPop(population, fitness_fn, decode_fn);

	%% Recording
	history.iterations(g) = createRecord(real_values_pop, fitness, objective_fn);

	%% TODO: Fitness transfert if minimizing.
	fitness = fitness_change_fn(fitness);
	
	%% Selection
	selection = selection_fn(fitness);
	mating_pool = population(UTILS.shuffle(selection), :);

	%% Crossover
	children = crossover(mating_pool, crossover_fn, Pc, context);

	%% Mutation
	%% TODO: This check can be done outside the loop.
	if (l == -1)
	  mutations = rand(N, var_count, 1) <= Pm;  %% Every allele that needs to mutate is 1 at the correponding index
	else
	  %% NOTE(MUTATIONS.bitFlip): (See corresponding notes in Crossover)
	  %% We may want mutation to be different for each variable, in that
	  %% case:
	  %%  - Replace 1 by dim(2)
	  %%  - Replace 'mask = UTILS.arrayToDec(mutations) .* ones(dim);'
	  %%    by 'mask = reshape(UTILS.arrayToDec(mutations), [], 2);'
	  mutations = rand(N, l, 1) <= Pm; %% Every allele that needs to mutate is 1 at the correponding index
	end

	population = mutation_fn(children, mutations, context);
  end

  [fitness, real_values_pop] = evalFitnessAndPop(population, fitness_fn, decode_fn);

  [~, index_best] = max(fitness);
  result = real_values_pop(index_best, :);
  
  history.iterations(G_max + 1) = createRecord(real_values_pop, fitness, objective_fn);
  
  [max_fitness, very_best_index] = max([history.iterations.maxFitness]);
  best_iteration = history.iterations(very_best_index);
  history.very_best = struct('value', best_iteration.bestIndividual(1, :), 'fitness', max_fitness, 'iteration', very_best_index);

  toc;
end

%% NOTE: Minimizing f(x) is maximizing g(x) = -f(x)
function [result, history] = minimize(obj_fn, fit_fn, constraints, config)
  [result, history] = maximize(obj_fn, @(varargin) -fit_fn(varargin{:}), constraints, config);
end

function result = defaultConfig
  global FITNESS_CHANGE;
  global SELECTION;
  global CROSSOVER;
  global MUTATION;
  
  result.N = 100; %% Population count
  result.G_max = 100; %% Max iteration count
  
  %% NOTE: 'binary' is just an integer representation (to get to the
  % actual value => v = (i / maxI) * (c(1) - c(0)) + c(0), with c the
  % constaints for this variable)
  result.l = 12; %% Chromosome length (IMPORTANT: must be in [1, 53])
  
  result.Pc = 0.5; %% Crossover probability
  result.Pm = 0.1; %% Mutation probability

  result.fitness_change_fn = FITNESS_CHANGE.linearScale;
  result.selection_fn = SELECTION.wheel;
  result.crossover_fn = CROSSOVER.singlePoint;
  result.mutation_fn = MUTATION.bitFlip;
end
