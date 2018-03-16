function Crossover
	   %CROSSOVER All crossover functions.
  
  global CROSSOVER;

  CROSSOVER.partial = @partial_;
end

function result = partial_(a, b)
  global UTILS;
  
  [N, len] = size(a);

  random_points = UTILS.randUniqueS(N, len, 2);

  result = zeros(N, 2 * len);
  all_indices = 1:len;
  
  for i = 1:N
	result(i, :) = partialMakeChildren_(a(i, :), b(i, :), all_indices, random_points(i, 1), random_points(i, 2));
  end
end

%% TODO: Make this vectorized (one we partial_ is vectorized too (as if..;))
function result = partialMakeChildren_(a, b, all_indices, p1, p2)
  indices = p1:p2;

  %% Indices not between p1 and p2
  out_indices = all_indices;
  out_indices(indices) = [];

  a_extracted_values = a(indices);
  b_extracted_values = b(indices);
  
  child_one = a;
  child_two = b;
  
  child_one(indices) = b_extracted_values;
  child_two(indices) = a_extracted_values;

  %% Compute parallel routes to resolve illegal solutions
  %% NOTE: This also makes some columns useless. But removing them
  %% would probably be slower than keeping them, so...
  %% (If we decide to remove them later on, know that you just need to do (with k being either i or j, but not both!):
  %% a_extracted_values(k) = []; b_extracted_values(k) = [];
  [i, j] = fastIntersect_(a_extracted_values, b_extracted_values);
  c = length(i);
  
  for k = 1:c
     a_extracted_values(i(k)) = a_extracted_values(j(k));
     b_extracted_values(j(k)) = b_extracted_values(i(k));
  end
  
  mapped = all_indices;
  mapped(a_extracted_values) = b_extracted_values;
  mapped(b_extracted_values) = a_extracted_values;

  child_one(out_indices) = mapped(child_one(out_indices));
  child_two(out_indices) = mapped(child_two(out_indices));
  
  
  %% TODO: Remove this! (or only enable it when debugging)
  %% NOTE: This is not fired anymore since we are using the loop above. It should be fine...
  n = all_indices(end);
  total_count = n * (n + 1);
  assert((sum(child_one, 2) + sum(child_two, 2)) == total_count);
  
  result = [child_one, child_two];
end

function [i, j] = fastIntersect_(a, b)
    [a, a_idx] = sort(a);
    [b, b_idx] = sort(b);
    
    i = sort(a_idx(ismembc(a, b)));
    j = sort(b_idx(ismembc(b, a)));
end