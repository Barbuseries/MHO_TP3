function Crossover
  global CROSSOVER;

  %% Binary
  CROSSOVER.singlePoint = multiPoint(1);
  CROSSOVER.multiPoint = @multiPoint;
  CROSSOVER.uniform = @uniform;


  %% Arithmetic
  CROSSOVER.whole_arithmetic = @(a, b) arithmetic_crossover_(1, a, b);
  CROSSOVER.local_arithmetic = @local_arithmetic;
  CROSSOVER.blend = @blend;
end

%% Binary crossovers
function h = multiPoint(n)
  h = @(a, b, l) multiPoint_(n, a, b, l);
end

function result = multiPoint_(n, a, b, l)
  global UTILS;
  
  if (n >= l)
	error('multipoint crossover: crossover count must be < chromosome length');
  end
  
  %% NOTE: According to the slides, it should be left to the user to
  %% specify weither or not variables are combined (and l may be
  %% different for each).
  %% NOTE/FIXME: This assumes the crossover point is the same for all
  %% variables. If it is not the case, change 'n' to be n times the
  %% number of variables and remove upper and lower multiplication by
  %% ones(size(a)) (see NOTE in combineWithMask).
  BY_COLUMN = 2;
  dim = size(a);
  [~, indices] = sort(rand(dim(1), l - 1), BY_COLUMN);
  points = sort(indices(:, 1:n), BY_COLUMN);

  %% TODO: Explain!
  flags = (2 .^ points) - 1;
  mask = UTILS.reduce(@bitxor, flags, 0);
  
  result = combineWithMask(a, b, mask, l);
end

%% TODO: Default value for p
%% TODO: Should we reverse the function order?
%% NOTE/FIXME: If t(a) and t(b) is negative and p is a relative sum,
%% the result is bogus! I _may_ have a fix (offseting t(a) and t(b),
%% but it does not work in Octave...)
function h = uniform(p, t)
  global UTILS;
  
  if (UTILS.isMatlab)
	is_function_handle = @(f) isa(f, 'function_handle');
  end
  
  if (isnumeric(p))
	if ((p < 0) | (p > 1))
	  error('uniform: p in [0, 1]')
	else
	  h = @(a, b, l) uniform_(p, a, b, l);
	end
  elseif (is_function_handle(p) & is_function_handle(t))
	%% TODO: If t is not defined, set to identity.
	h = @(a, b, l) uniform_(p(t(a), t(b)), a, b, l);
  else
	error('uniform: either p must be a real in [0, 1] or p and t must be two function handles')
  end
end

function result = uniform_(p, a, b, l)
  global UTILS;
  %% TODO: Check p in [0, 1]?

  %% NOTE: According to the slides, it should be left to the user to
  %% specify weither or not variables are combined (and l may be
  %% different for each).
  %% NOTE/FIXME: This assumes the crossover point is the same for all
  %% variables. If it is not the case, change '1' to be the number
  %% of variables and remove upper and lower multiplication by
  %% ones(size(a)) (see NOTE in combineWithMask).
  %% TODO: Explain!
  %% NOTE: Btw, if p == 0.5, the mask could just be a random integer
  %% between 0 and (2^l - 1).
  %% But this rarely ever happens, so...
  dim = size(a);
  mask_as_array = rand(dim(1), l, 1) <= p;
  mask = UTILS.arrayToDec(mask_as_array);
  
  result = combineWithMask(a, b, mask, l);
end

function result = combineWithMask(a, b, mask, l)
  max_val = 2^l - 1;

  %% NOTE: This is to use array application of bit functions, so I do
  %% not have to manually create a loop (which is slower).
  mask = mask .* ones(size(a));
  inv_mask = bitxor(mask, max_val);
  
  result = makeChildren(a, b, mask, inv_mask);
end

%% TODO: Find a better name.
function result = makeChildren(a, b, m, im)
  c1 = bitor(bitand(a, m), bitand(b, im));
  c2 = bitor(bitand(b, m), bitand(a, im));
  
  result = [c1, c2];
end


%% Arithmetic crossovers
function result = local_arithmetic(a, b)
  dim = size(a);
  var_count = dim(2);

  result = arithmetic_crossover_(var_count, a, b);
end

function result = arithmetic_crossover_(n, a, b)
  dim = size(a);
  alpha = rand(dim(1), n);
  beta = 1 - alpha;

  result = [(a .* alpha) + (beta .* b), (b .* alpha) + (beta .* a)];
end

%% TODO: It does not seem correct to need for the user to give the
%% constraints once again. This should be taken care of by Ga (but
%% only a few crossover methods actually create children outside the
%% range, so...).
function h = blend(constraints, alpha)
  if ~exist('alpha', 'var')
	alpha = 0.5;
  end
  
  h = @(a, b) blend_(constraints, alpha, a, b);
end

function result = blend_(constraints, alpha, a, b)
  dim = size(a);
  N = dim(1);
  var_count = dim(2);
  
  max_vals = a .* (a >= b) + b .* (b > a);
  min_vals = a .* (a <= b) + b .* (b < a);

  delta = alpha * (max_vals - min_vals);
  lb = min_vals - delta;
  ub= max_vals + delta;

  lowest = constraints(:, 1)';
  biggest = constraints(:, 2)';

  %% YES!
  result = [blend_child(lowest, biggest, lb, ub, N, var_count), blend_child(lowest, biggest, lb, ub, N, var_count)];
end

function result = blend_child(lowest, biggest, lb, ub, N, var_count)
  result = (ub - lb) .* rand(N, var_count) + lb;
  result = max(min(result, biggest), lowest);
end

