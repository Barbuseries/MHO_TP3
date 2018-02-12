function Replacement
  global REPLACEMENT;

  REPLACEMENT.none = [];
  REPLACEMENT.value = @value;
  REPLACEMENT.old = @old;
  REPLACEMENT.random = @random;
end

function result = value(fitness, ~, lambda)
		  %VALUE Replace the worst individuals based on their fitness.

  [~, ordered] = sort(fitness);
  result = ordered(1:lambda);
end

function result = old(~, iteration_appeared_in, lambda)
								%OLD Replace the oldest individuals.
  
  oldest_age = min(iteration_appeared_in);
  oldest = find(iteration_appeared_in == oldest_age);

  N = length(oldest);
  random_index = randi(N, lambda, 1);
  
  result = oldest(random_index);
end


function result = random(fitness, ~, lambda)
  N = length(fitness);
  result = randi(N, lambda, 1);
end
