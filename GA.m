%% Includes
Utils;
Crossover;
Mutation;

function export = GA
  export.maximize = @maximize;
  export.minimize = @minimize;

  export.defaultConfig = @defaultConfig;

  export.showHistory = @showHistory;
end

function result = initialGeneration(N, constraints, l)
  max_val = 2**l-1;
  var_count = size(constraints)(1);

  result = randi(max_val, N, var_count);
end

function result = evalFitness(population, fn, constraints, l)
  real_values = Utils.dec2val(population, constraints, l);
  result = fn(real_values);
end

%% TODO: This actually just a wheel selection.
%%       Move this function (and rename) to a Selection.m file.
%%       Add a field in config to specify the selection_fn.
%%       Let selection functions handle negative fitness values.
function result = selectBests(fitness)
  min_fitness = min(fitness);
  
  %% Remove negative fitness and a little more, so their relative
  %% fitness is not 0 (not selectable).
  if (min_fitness < 0)
	fitness -= 2 * min(fitness);
  end
  
  cumulative_sum = cumsum(fitness / sum(fitness));

  %% We need to select as many individuals as there already are.
  wheel = rand(length(fitness), 1);

  %% NOTE: I did not find a way to 'find' (pun intended) in a matrix
  %% row-wise (meaning that I want, for each row, the result of the
  %% find for this row (it must be because matrices row and column
  %% sizes must be constant)) without introducing an explicit
  %% loop. Therefore, instead of using find, I use max which returns
  %% (as well as the value, which is one anyway) the first index
  %% corresponding to this value. To make it operate on rows, the
  %% second parameter is ignored and I must give it a dimension
  %% parameter (BY_ROW).
  %% NOTE(@perf): Replacing the for loop by max made this function at
  %% least 20 times faster. There may be a way to use find here in the
  %% end, but it is fast enough anyway.
  BY_ROW = 2;
  [~, result] = max(cumulative_sum' >= wheel, [], BY_ROW);
end

function result = crossover(mating_pool, crossover_fn, l, Pc)
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
  go_through_crossover = crossover_fn(go_through_crossover(:, min_b),
									  go_through_crossover(:, max_b),
									  l);

  %% Flatten the result to have [i1; i2; ...] again, instead of
  %% [ [i1, i2]; [i3, i4]; ... ]
  result = reshape([unchanged; go_through_crossover]', var_count, [])';
end

%% TODO: Default value for iterations to be -1.
function showHistory(problem, history, iterations)
  var_count = size(history(1).bestIndividual)(2);

  if (iterations == -1)
	iterations = 1:length(history);
  end
  
  values = history(iterations);
  
  figure(1);
  clf;
  hold on;

  best_individual_format = 'g*';
  best_individual_size = 10;

  [maxFitness, very_best_index] = max([values.maxFitness]);
  very_best = values(very_best_index).bestIndividual;
  
  plot(iterations, [values.maxFitness], '-+');
  
  plot(iterations(very_best_index), maxFitness, best_individual_format, 'markersize', best_individual_size);
  
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

	%% TODO: Show iteration order
	%% TODO: Find my old gradient function and use it here.
	%% TODO: Show population at each iteration
	if (var_count == 1)
	  x = Utils.linspacea(problem.constraints, 1000);
	  
	  plot(x, problem.objective_fn(x), objective_fn_format);
	  plot(best_x, problem.objective_fn(best_x), individuals_format);

	  plot(very_best, maxFitness, best_individual_format, 'markersize', best_individual_size);
	  ylabel('F(x)');
	else
	  domain = Utils.linspacea(problem.constraints, 200); %% Less points because N^2...
	  x = domain(1, :);
	  y = domain(2, :);

	  %% FIXME: There is an offset between the result of objective_fn
	  %% on the meshgrid and the individuals' coordinates... weird!
	  [xx, yy] = meshgrid(x, y);
	  z = problem.objective_fn(xx, yy)';
	  mesh(x, y, z);

	  best_y = best_individuals(:, 2);
	  plot3(best_x, best_y, problem.objective_fn(best_x, best_y), individuals_format);

	  plot3(very_best(1), very_best(2), maxFitness, best_individual_format, 'markersize', best_individual_size);

	  ylabel('Best individual y');
	  zlabel('F(x, y)');
	end
	
	xlabel('Best individual x');
	title('Objective function F and best individuals at each iteration');
  else
	disp('Too many variables to plot objective function.');
  end
end

%% TODO: Save objective_fn value (technically, it should be saved
%% instead of the fitness value, but one can be evaluated here, and
%% another not (variable number of arguments))...
function result = createRecord(population, fitness, constraints, l)
  result.population = Utils.dec2val(population, constraints, l);
  result.fitness = fitness;

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
%% - it's fitness
%% - the best individual
%% - it's fitness
function [result, history] = maximize(fn, constraints, config)
  %% TODO: Parameter check and default value.
  N = config.N;
  l = config.l;
  G_max = config.G_max;
  Pc = config.Pc;
  Pm = config.Pm;
  crossover_fn = config.crossover_fn;
  mutation_fn = config.mutation_fn;
  
  _starting_time = time();

  var_count = size(constraints)(1);
  population = initialGeneration(N, constraints, l);
  
  history(1:G_max+1) = struct;

  for g = 1:G_max
	%% Evaluation
	fitness = evalFitness(population, fn, constraints, l);

	%% Recording
	history(g) = createRecord(population, fitness, constraints, l);
	
	%% Selection
	selection = selectBests(fitness);
	mating_pool = population(Utils.shuffle(selection), :);

	%% Crossover
	children = crossover(mating_pool, crossover_fn, l, Pc);

	%% Mutation
	population = mutation_fn(children, l, Pm);
  end

  fitness = evalFitness(population, fn, constraints, l);

  [~, index_best] = max(fitness);
  best = population(index_best, :);
  
  result = Utils.dec2val(best, constraints, l);

  history(G_max + 1) = createRecord(population, fitness, constraints, l);

  fprintf(1, 'Duration: %ds\n', time - _starting_time);
end

%% NOTE: Minimizing f(x) is maximizing g(x) = -f(x)
function [result, history] = minimize(fn, constraints, config)
  [result, history] = maximize(@(p) -fn(p), constraints, config);
end

function result = defaultConfig
  result.N = 100; %% Population count
  result.G_max = 100; %% Max iteration count
  
  %% NOTE: 'binary' is just an integer representation (to get to the
  % actual value => v = (i / maxI) * (c(1) - c(0)) + c(0), with c the
  % constaints for this variable)
  result.l = 12; %% Chromosome length (IMPORTANT: must be in [1, 53])
  
  result.Pc = 0.5; %% Crossover probability
  result.Pm = 0.1; %% Mutation probability
  
  result.crossover_fn = Crossover.singlePoint;
  result.mutation_fn = Mutation.bitFlip;
end
