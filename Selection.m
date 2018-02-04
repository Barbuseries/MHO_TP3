function Selection
  global SELECTION;
  
  SELECTION.wheel = @wheel;
  SELECTION.stochasticUniversalSampling = @stochasticUniversalSampling;
end

function result = wheel(fitness)
  global UTILS;
  
  [cumulative_sum, wheel] = wheelInner_(fitness);
  result = UTILS.select(cumulative_sum, wheel);
end

function [cumulative_sum, wheel] = wheelInner_(fitness)
  %% TODO: This replaced by a linear scale change, I think. In that
  %% case, it coule be used to modify the fitness _before_ it is used
  %% for the selection. So, this below would be removed, and the same
  %% goes for what is inside stochasticUnivelsalSampling.
  min_fitness = min(fitness);
  
  %% Remove negative fitness and a little more, so their relative
  %% fitness is not 0 (not selectable).
  if (min_fitness < 0)
	fitness = fitness - 2 * min(fitness);
  end
  
  cumulative_sum = cumsum(fitness / sum(fitness));

  %% We need to select as many individuals as there already are.
  wheel = rand(length(fitness), 1);
end

function result = stochasticUniversalSampling(fitness)
  global UTILS;
  
  N = length(fitness);

  min_fitness = min(fitness);
  
  %% Remove negative fitness and a little more, so their relative
  %% fitness is not 0 (not selectable).
  if (min_fitness < 0)
	fitness = fitness - 2 * min(fitness);
  end
  
  cumulative_sum = cumsum(fitness / sum(fitness));

  %% TODO: Explain!
  delta = 1/N;
  start_pos = delta * rand();
  pointers = delta * (0:(N-1)) + start_pos;

  result = UTILS.select(cumulative_sum, pointers');
end
