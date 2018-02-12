function Mutation
					  %MUTATION All mutation functions.
					  %
					  % Binary mutations
					  %  bitFlip
					  % 
					  % Arithmetic mutations
					  %  uniform
					  %  boundary
					  %  normal(???)
					  %  normalN(???)
					  %  polynomial(N), N > 0  %% TODO: Check interval
					  %  nonUniform(B) %% TODO: Check interval
					  %  
					  % See also MUTATION>BITFLIP, MUTATION>UNIFORM,
					  % MUTATION>BOUNDARY, MUTATION>NORMAL,
					  % MUTATION>NORMALN, MUTATION>POLYNOMIAL,
					  % MUTATION>NONUNIFORM
  global MUTATION;

  %% Binary
  MUTATION.bitFlip = @bitFlip;

  %% Arithmetic
  MUTATION.uniform = @uniform;
  MUTATION.boundary = @boundary;
  MUTATION.normal = @normal;
  MUTATION.normalN = @normalN;
  MUTATION.polynomial = @polynomial;
  MUTATION.nonUniform = @nonUniform;
end

%% Binary
function result = bitFlip(children, mutations, ~)
	 %BITFLIP For each element I in mutations where mutations(I) == 1,
	 % invert the corresponding bit in children.
  
  global UTILS;
  
  dim = size(children);
  var_count = dim(2);

  %% 'mutations' contains 1s and 0s, that we use to represent the
  %% mutation (1s flip the bit when xor-ing, 0s do not).
  %% 'reshape' is used to handle different masks for each variable.
  %% (We have a matrix of Nxlxvar_count 1s and 0s, that we them
  %% convert to Nxvar_count integers)
  mask = reshape(UTILS.arrayToDec(mutations), [], var_count);

  result = bitxor(children, mask); %% Do a flip!
end

%% Arithmetic
function result = uniform(children, mutations, context)
	 %BITFLIP For each element I in mutations where mutations(I) == 1,
	 % assign a random value inside CONTEXT.CONSTRAINTS to the
	 % corresponding variable in children.
  
  global UTILS;
    
  dim = size(children);

  N = dim(1);
  
  %% Children which do not mutate (mutations == 0) keep their values.
  %% Otherwhise, they get a random value inside the constraints.
  result = children .* (mutations == 0) + mutations .* UTILS.randomIn(context.constraints, N);
end

function result = boundary(children, mutations, context)
	%BOUNDARY For each element I in mutations where mutations(I) == 1,
	% draw a random number U in ]0, 1[. If assign U > 0.5, set the
	% corresponding variable in children to the upper bound in
	% CONTEXT.CONSTRAINTS, otherwhise, set it to the lower bound.
  
  constraints = context.constraints;
  
  dim = size(children);

  N = dim(1);
  var_count = dim(2);
  
  %% If we do not mutate, mutation is 0.
  %% Otherwhise, it is set to a random number in ]0, 1[.
  mutations = mutations .* rand(N, var_count, 1); 
  
  keep = children .* (mutations == 0); %% Keep value (or zero if not related)
  clamp_up = constraints(:, 2)' .* (mutations > 0.5); %% Set to upper bound (or zero if not related)
  clamp_down = constraints(:, 1)' .* ((mutations > 0) & (mutations <= 0.5)); %% Set to lower bound (or zero if not related)
  
  result = keep + clamp_up + clamp_down;
end

%% TODO: Should the the sigma be random or set by the user?
function result = normal(children, mutations, context)
  %% TODO: Doc...
  
  dim = size(children);
  
  N = dim(1);
  
  %% TODO: Explain!
  sigma = rand(N, 1) .* (mutations == 1);
  result = normalAnyInner_(sigma, children, context);
end

%% TODO: Should the the sigma be random or set by the user?
function result = normalN(children, mutations, context)
  %% TODO: Doc...
  
  dim = size(children);
  
  N = dim(1);
  var_count = dim(2);
  
  %% TODO: Explain!
  sigma = rand(N, var_count) .* (mutations == 1);
  result = normalAnyInner_(sigma, children, context);
end

%% TODO: Explain!
function result = normalAnyInner_(sigma, children, context)
  %% TODO: Doc...
  
  constraints = context.constraints;
  clamp_fn = context.clamp_fn;
  
  non_zero = (sigma ~= 0);
  sigma_non_zero = sigma(non_zero);
  sigma(non_zero) = sigma_non_zero .* normrnd(0, 1, size(sigma_non_zero));
  
  lowest = constraints(:, 1)';
  biggest = constraints(:, 2)';
  
  result = children + sigma;
  result = clamp_fn(result, lowest, biggest);
end

function h = polynomial(n)
  %% TODO: Doc...
  
  h = @(c, m, cx) polynomialInner_(n, c, m, cx);
end


function result = polynomialInner_(n, children, mutations, context)
  %% TODO: Doc...
  
  constraints = context.constraints;
  clamp_fn = context.clamp_fn;
  
  dim = size(children);
  
  N = dim(1);
  var_count = dim(2);
  
  delta_max = (constraints(:, 2) - constraints(:, 1))';

  non_zero = (mutations == 1);
  u = rand(N, var_count);

  u_below = (u < 0.5);
  u_above = ~u_below;

  %% TODO: Explain!
  inv = 1 / (n + 1);
  xi = ((2 * u).^inv  - 1) .* u_below + (1 - (2 * (1 - u)).^inv) .* u_above;

  lowest = constraints(:, 1)';
  biggest = constraints(:, 2)';
  
  result = children + delta_max .* xi .* non_zero;
  result = clamp_fn(result, lowest, biggest);
end

function h = nonUniform(b)
  %% TODO: Doc...
  
  h = @(c, m, cx) nonUniformInner_(b, c, m, cx);
end

function result = nonUniformInner_(b, children, mutations, context)
  %% TODO: Doc...
  
  constraints = context.constraints;
  clamp_fn = context.clamp_fn;
  
  g = context.iteration;
  G_max = context.G_max;

  dim = size(children);
  N = dim(1);
  var_count = dim(2);

  lowest = constraints(:, 1)';
  biggest = constraints(:, 2)';

  non_zero = (mutations == 1);
  u = rand(N, var_count);

  u_below = (u < 0.5);
  u_above = ~u_below;

  %% TODO: Explain!
  inv = ((1 - g) / G_max)^b;
  delta_g = (1 - u.^inv);
  
  delta_above = (biggest - children) .* delta_g .* u_above;
  delta_below = (children - lowest) .* delta_g .* u_below;

  result = children + (delta_above - delta_below) .* non_zero;
  result = clamp_fn(result, lowest, biggest);
end
