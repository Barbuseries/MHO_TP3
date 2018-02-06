function Mutation
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
  global UTILS;
  
  dim = size(children);
  %% TODO: Explain!
  mask = UTILS.arrayToDec(mutations) .* ones(dim);

  result = bitxor(children, mask); %% Do a flip!
end

%% Arithmetic
function result = uniform(children, mutations, context)
  global UTILS;
    
  dim = size(children);

  N = dim(1);
  
  %% TODO: Explain!
  %% TODO(@perf): This can probably be improved (I hope).
  result = children .* (mutations == 0) + mutations .* UTILS.randomIn(context.constraints, N);
end

function result = boundary(children, mutations, context)
  constraints = context.constraints;
  
  dim = size(children);

  N = dim(1);
  var_count = dim(2);
  
  %% TODO(@perf): This can probably be improved (I hope).
  %% TODO: Explain!
  mutations = mutations .* rand(N, var_count, 1); 
  
  keep = children .* (mutations == 0);
  clamp_up = constraints(:, 2)' .* (mutations > 0.5);
  clamp_down = constraints(:, 1)' .* ((mutations > 0) & (mutations <= 0.5));
  
  result = keep + clamp_up + clamp_down;
end

%% TODO: Should the the sigma be random or set by the user?
function result = normal(children, mutations, context)
  constraints = context.constraints;
  
  dim = size(children);
  
  N = dim(1);
  
  %% TODO: Explain!
  sigma = rand(N, 1) .* (mutations == 1);
  result = normalAnyInner_(sigma, children, context);
end

%% TODO: Should the the sigma be random or set by the user?
%% TODO: This was not run!
function result = normalN(children, mutations, context)
  dim = size(children);
  
  N = dim(1);
  var_count = dim(2);
  
  %% TODO: Explain!
  sigma = rand(N, var_count) .* (mutations == 1);
  result = normalAnyInner_(sigma, children, context);
end

%% TODO: Explain!
function result = normalAnyInner_(sigma, children, context)
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
  h = @(c, m, cx) polynomialInner_(n, c, m, cx);
end


function result = polynomialInner_(n, children, mutations, context)
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
  h = @(c, m, cx) nonUniformInner_(b, c, m, cx);
end

function result = nonUniformInner_(b, children, mutations, context)
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
