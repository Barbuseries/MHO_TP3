function Mutation
  %MUTATION All mutation functions.
  
  global MUTATION;

  MUTATION.simpleInverse = @simpleInverse_;
end

function result = simpleInverse_(children, mutations)
  global UTILS;

  [~, len] = size(children);

  mutation_indices = find(mutations == 1);
  mutation_count = length(mutation_indices);
  
  random_points = UTILS.randUniqueS(mutation_count, len, 2);
  result = children;

  for i = 1:mutation_count
	index = mutation_indices(i);
    
	sequence = random_points(i, 1):random_points(i, 2);
    inv_sequence = random_points(i, 2):-1:random_points(i, 1);
    
	result(index, sequence) = result(index, inv_sequence);
  end
end
