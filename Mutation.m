function export = Mutation
  export.bitFlip = @bitFlip;
end


function result = bitFlip(child, l, Pm)
  mutation_indices = find(rand(1, l) <= Pm); %% Every allele that needs to mutate.
  
  if (length(mutation_indices == 0))
	  result = child;
  end
  
  flag = sum(2.**(mutation_indices - 1)); %% Compute the flag associated to the bit indices
  result = bitxor(child, flag); %% Do a flip!
end
