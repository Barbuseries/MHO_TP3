function Mutation
  %MUTATION All mutation functions.
  
  global MUTATION;

  MUTATION.simpleInverse = @simpleInverse_;
end

function result = simpleInverse_(children, mutations)
  [~, len] = size(children);

  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);

  random_start = randi(len, mutation_count, 1);
  
  %% A locus count of 1 would not do anything. Maybe it would be ok,
  %% but I _want_ something to happen.
  random_locus_count = randi(len - 2, mutation_count, 1) + 1;
  random_end = random_start + random_locus_count - 1;
  
  result = children;

  for i = 1:mutation_count
	index = mutation_indices(i);

	%% Start is always within bounds
	index_start = random_start(i);
	%% The sequence can wrap (start + locus_count > len)
	absolute_index_end = random_end(i);

	inv_sequence = absolute_index_end:-1:index_start;

	%% To make it easier to get the sequence
    repeated = [result(index, :), result(index, :)];
	inv_pattern = repeated(inv_sequence);

	%% If the sequence is completly within bounds (absolute_index_end
	%% <= len), second part is empty.
	%% Otherwhise, this takes care of the part between start and len,
	%% and second part corresponds to the wrapping.
	index_end = min(absolute_index_end, len);
    first_part = index_start:index_end;
	first_part_count = length(first_part);
    
    new_index_end= (absolute_index_end - len);
    second_part = 1:new_index_end;
	
	result(index, first_part) = inv_pattern(1:first_part_count);
	result(index, second_part) = inv_pattern((first_part_count+1):end);
  end
end
