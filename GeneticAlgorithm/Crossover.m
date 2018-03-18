function Crossover
	   %CROSSOVER All crossover functions.
  
  global CROSSOVER;

  CROSSOVER.partial = @partial_;
  CROSSOVER.position = @position_;
  CROSSOVER.cycle = @cycle_;
end

%% Partial
function result = partial_(a, b)
  global UTILS;
  
  [N, len] = size(a);

  random_points = UTILS.randUniqueS(len, N, 2);

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
  
  result = [child_one, child_two];
end

function [i, j] = fastIntersect_(a, b)
    [a, a_idx] = sort(a);
    [b, b_idx] = sort(b);
    
    i = sort(a_idx(ismembc(a, b)));
    j = sort(b_idx(ismembc(b, a)));
end


%% Position
function result = position_(a, b)
  global UTILS;

  [N, len] = size(a);

  random_index_count = randi(len, N, 1);
  child_one = a;
  child_two = b;

  for i = 1:N
	random_indices = UTILS.randUnique(len, 1, random_index_count(i));
    
    remaining_indices = 1:len;
	remaining_indices(random_indices) = [];

	a_values = a(i, :);
	b_values = b(i, :);
    
    %% TODO(@perf): See if setdiff is faster.
    %% Yes, it works (because a and b both have the same elements).
    [~, a_sorted_indices] = sort(a_values);
	[~, b_sorted_indices] = sort(b_values);
    b_in_a_indices = a_sorted_indices(b_values(random_indices));
    a_in_b_indices = b_sorted_indices(a_values(random_indices));
    
    a_remaining_values = a_values;
    b_remaining_values = b_values;
    a_remaining_values(b_in_a_indices) = [];
	b_remaining_values(a_in_b_indices) = [];

	child_one(i, remaining_indices) = b_remaining_values;
	child_two(i, remaining_indices) = a_remaining_values;
  end

  result = [child_one, child_two];
end

%% Cycle
function result = cycle_(a, b)
  [N, len] = size(a);
  
  child_one = zeros(N, len);
  child_two = zeros(N, len);

  for i = 1:N
	parent_a = a(i, :);
	parent_b = b(i, :);

	child_one(i, :) = cycleInner_(parent_a, parent_b, len);
	child_two(i, :) = cycleInner_(parent_b, parent_a, len);
  end
  
  result = [child_one, child_two];
end

function result = cycleInner_(parent_a, parent_b, len)
  result = zeros(1, len);

  start_index = 1;
  index = start_index;
  while(index >= 1)
	value = parent_a(index);
    next_index = parent_b(value);
    
    result(index) = value;
    
	if (next_index ~= start_index)
	  index = next_index;
	else
	  start_index = find((result == 0), 1); %% Find first empty slot;
	  index = start_index;
	end
  end
end
