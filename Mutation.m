function export = Mutation
  export.bitFlip = @bitFlip;
end


function result = bitFlip(children, l, Pm)
  %% NOTE: (See corresponding notes in Crossover)
  %% We may want mutation to be different for each variable, in that
  %% case, replace 1 by dim(2) and remove the multiplication by
  %% ones(dim).
  
  dim = size(children);
  %% TODO: Explain!
  mask_as_array = rand(dim(1), l, 1) <= Pm; %% Every allele that needs to mutate is 1 at the correponding index
  mask = Utils.arrayToDec(mask_as_array) .* ones(dim);

  result = bitxor(children, mask); %% Do a flip!
end
