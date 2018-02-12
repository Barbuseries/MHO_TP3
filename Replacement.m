function Replacement
  global REPLACEMENT;

  REPLACEMENT.none = [];
  REPLACEMENT.value = @value;
  REPLACEMENT.old = @old;
end

%% TODO?: Add a parameter to know how many children are needed? (1 or 2)
function result = value(fitness, ~)
		  %VALUE Replace the worst individuals based on their fitness.
  
  [~, result] = sort(fitness);
end

function result = old(~, iteration_appeared_in)
  oldest_age = min(iteration_appeared_in);
  oldest = find(iteration_appeared_in == oldest_age);

  N = length(oldest);
  %% At most, replacement must return
  %% two indices. And we do not know how much are needed. But
  %% returning two instead of one does not take too much time.
  random_index = randi(N, 2, 1);
  
  result = oldest(random_index);
end
