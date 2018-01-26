%% Includes
Utils;
Crossover;
Mutation;

function export = GA
  export.maximize = @maximize;
  export.minimize = @minimize;
  export.defaultConfig = @defaultConfig;
end

function result = initialGeneration(N, constraints, l)
  max_val = 2**l-1;
  var_count = size(constraints)(1);

  result = randi(max_val, N, var_count);
end

%% Convert an individual's decimal values between 0 and (2**l -1) to
%% real values (between their corresponding min and max constraints).
function result = dec2val(val, constraints, l)
  max_val = 2**l-1;
  result = ((val / max_val) .* (constraints(:, 2) - constraints(:, 1))') + constraints(:, 1)';
end

function result = evalFitness(population, fn, constraints, l)
  max_val = 2**l-1;
  real_values = dec2val(population, constraints, l);
  result = fn(real_values);
end

function result = selectBests(fitness)
  %% TODO: Some selection methods do not care about negative fitness values.
  %% When implementing them, move this to the ones who care and assert?

  min_fitness = min(fitness);
  
  %% Remove negative fitness and a little more, so their relative
  %% fitness is not 0 (not selectable).
  if (min_fitness < 0)
	fitness -= 2 * min(fitness);
  end
  
  relative_fitness = fitness / sum(fitness);

  cumulative_sum = cumsum(relative_fitness);

  count = length(relative_fitness);
  result = zeros(1, count);

  %% TODO: I'm sure there is a way to one-line this.
  %% AND I WILL FIND IT!
  i = 1;
  while (i <= count)
	rand_val = rand();

	result(i) = find(cumulative_sum >= rand_val, 1, 'first');

	i += 1;
  endwhile
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
  unchanged = mating_pool(setdiff(1:length(mating_pool), indices), :); %% Find which pair did _not_ crossover
  go_through_crossover = crossover_fn(go_through_crossover(:, min_b),
									  go_through_crossover(:, max_b),
									  l);

  %% Flatten the result to have [i1; i2; ...] again, instead of
  %% [ [i1, i2]; [i3, i4]; ... ]
  result = reshape([unchanged; go_through_crossover]', var_count, [])';
end

function result = mutate(children, mutation_fn, l, Pm)
  count = length(children);
  result = zeros(size(children));
  
  %% NOTE: As bitxor does not work as intended if both X and Y are
  %% arrays, I can not one-line this...
  for i = 1:count
	result(i, :) = mutation_fn(children(i, :), l, Pm);
  endfor
end

function plotHistory(history)
  %% TODO: Find my old gradient function and use it here.
  colors = ["r", "g", "b", "k", "y", "m"];
  count = length(history.population);
  value_count = length(history.population(1, :, 1));
  
  clf;
  hold on;
  
  if (value_count == 1)
	for i = 1:count
	  color_index = mod(i - 1, length(colors)) + 1;
	  values = history.population(:, :, i);
	  
	  plot(values, history.fitness(i), sprintf(".%s", colors(color_index)));
	endfor
  elseif (value_count == 2)
	for i = 1:count
	  color_index = mod(i - 1, length(colors)) + 1;
	  values = history.population(:, :, i);

	  plot3(values(:, 1), values(:, 2), history.fitness(:, i), sprintf("+-%s", colors(color_index)));
	endfor
  else
	error("sorry");
  endif
end

%% Maximize fn whose parameters are defined inside the given
%% constraints.
%% fn must only take one parameter. This parameter contains as many
%% columns as there are constraints. (If three constraints are given,
%% fn receives a parameter with three columns)
%%
%% Return the best individual from the last iteration as well as an
%% history which contains all individuals and their fitness at each
%% iteration.
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
  
  population = initialGeneration(N, constraints, l);
  history = {};

  %% TODO: Change to contain G_max + 1 'iteration' structs (so we can
  %% add info such as max / average fitness, ...)
  history.population = zeros(N, size(constraints)(1), G_max + 1);
  history.fitness = zeros(N, G_max + 1);
  
  history.population(:, :, 1) = population(:, :);

  for g = 1:G_max
	%% Evaluation
	fitness = evalFitness(population, fn, constraints, l);
	
	%% Selection
	selection = selectBests(fitness);
	mating_pool = population(Utils.shuffle(selection), :);

	%% Crossover
	children = crossover(mating_pool, crossover_fn, l, Pc);

	%% Mutation
	population = mutate(children, mutation_fn, l, Pm);

	history.population(:, :, g) = population(:, :);
	history.fitness(:, g) = fitness(:);
  endfor

  fitness = evalFitness(population, fn, constraints, l);
  [~, index_best] = max(fitness);
  best = population(index_best, :);
  
  result = dec2val(best, constraints, l);

  fprintf(1, "Duration: %ds\n", time - _starting_time);
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
