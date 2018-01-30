function Mutation
  global MUTATION;

  %% Binary
  MUTATION.bitFlip = @bitFlip;

  %% Arithmetic
  MUTATION.uniform = @uniform;
  MUTATION.boundary = @boundary;
end

%% TODO: Seems like what is called here 'mask_as_array' and in other
%% places 'mutations' can be moved out of this and just be passed as a
%% parameter (instead of Pm).
%% Which is somewhat logical, crossover methods do not care about Pc,
%% why should mutations method care about Pm? They change on _how_
%% they modify things, not when.
function result = bitFlip(children, l, mutations)
  global UTILS;
  
  %% NOTE: (See corresponding notes in Crossover)
  %% We may want mutation to be different for each variable, in that
  %% case, replace 1 by dim(2) and remove the multiplication by
  %% ones(dim).
  
  dim = size(children);
  %% TODO: Explain!
  mask = UTILS.arrayToDec(mutations) .* ones(dim);

  result = bitxor(children, mask); %% Do a flip!
end

function result = uniform(children, constraints, mutations)
  global UTILS;
  
  dim = size(children);
  dim2 = size(constraints);

  N = dim(1);
  
  %% TODO: Explain!
  %% TODO(@perf): This can probably be improved (I hope).
  result = children .* (mutations == 0) + mutations .* UTILS.randomIn(constraints, N);
end

function result = boundary(children, constraints, mutations)
  global UTILS;
  
  dim = size(children);
  dim2 = size(constraints);

  N = dim(1);
  var_count = dim2(1);
  
  %% TODO(@perf): This can probably be improved (I hope).
  %% TODO: Explain!
  mutations = mutations .* rand(N, var_count, 1); 
  
  keep = children .* (mutations == 0);
  clamp_up = constraints(:, 2)' .* (mutations > 0.5);
  clamp_down = constraints(:, 1)' .* ((mutations > 0) & (mutations <= 0.5));
  
  result = keep + clamp_up + clamp_down;
end
