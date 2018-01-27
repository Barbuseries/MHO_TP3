function export = Crossover
  export.singlePoint = multiPoint(1);
  export.multiPoint = @multiPoint;
  export.uniform = @uniform;
end

%% NOTE: There _may_ be a way to merge singlePoint and multiPoint into
%% the same function. But it would make my head explode, so no.
%% NOTE (following): Oh man, I really did it...

function h = multiPoint(n)
  h = @(a, b, l) _multiPoint(n, a, b, l);
end

function result = _multiPoint(n, a, b, l)
  if (n >= l)
	error('multipoint crossover: crossover count must be < chromosome length');
  end
  
  %% NOTE: According to the slides, it should be left to the user to
  %% specify weither or not variables are combined (and l may be
  %% different for each).
  %% NOTE/FIXME: This assumes the crossover point is the same for all
  %% variables. If it is not the case, change 'n' to be n times the
  %% number of variables and remove upper and lower multiplication by
  %% ones(size(a)) (see NOTE in combine_with_mask).
  %% TODO: Explain!
  [~, indices] = sort(rand(size(a)(1), l - 1), 2);
  points = sort(indices(:, 1:n), 2);

  %% TODO: Explain!
  flags = (2 .** points) - 1;
  mask = Utils.reduce(@bitxor, flags, 0);
  
  result = combine_with_mask(a, b, mask, l);
end

%% TODO: Default value for p
function h = uniform(p, t)
  if (isnumeric(p))
	if ((p < 0) | (p > 1))
	  error("uniform: p in [0, 1]")
	else
	  h = @(a, b, l) _uniform(p, a, b, l);
	end
  elseif (is_function_handle(p) & is_function_handle(t))
	%% TODO: Should we reverse the function order?
	%%       If t is not defined, set to identity.  
	h = @(a, b, l) _uniform(p(t(a), t(b)), a, b, l);
  else
	error("uniform: either p must be a real in [0, 1] or p and t must be two function handles")
  end
end

function result = _uniform(p, a, b, l)
  %% TODO: Check p in [0, 1]?
  
  %% NOTE: According to the slides, it should be left to the user to
  %% specify weither or not variables are combined (and l may be
  %% different for each).
  %% NOTE/FIXME: This assumes the crossover point is the same for all
  %% variables. If it is not the case, change '1' to be the number
  %% of variables and remove upper and lower multiplication by
  %% ones(size(a)) (see NOTE in combine_with_mask).
  %%TODO: Explain!
  mask_as_array = rand(size(a)(1), l, 1) >= p;
  
  %% TODO: Explain!
  mask = Utils.reduce(@(a, b) a * 2 + b, mask_as_array, 0);
  
  result = combine_with_mask(a, b, mask, l);
end

function result = combine_with_mask(a, b, mask, l)
  max_val = 2**l - 1;

  %% NOTE: This is to use array application of bit functions, so I do
  %% not have to manually create a loop (which is / should be / most
  %% of the time is slower).
  mask = mask .* ones(size(a));
  inv_mask = bitxor(mask, max_val);
  
  result = make_children(a, b, mask, inv_mask);
end

%% TODO: Find a better name.
function result = make_children(a, b, m, im)
  c1 = bitor(bitand(a, m), bitand(b, im));
  c2 = bitor(bitand(b, m), bitand(a, im));
  
  result = [c1, c2];
end
