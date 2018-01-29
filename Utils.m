function Utils
  %% NOTE/TODO(@perf): Utils is evaluated in many places, this an overhead of
  %% ~10%.
  %% Making export persistent removes most of this overhead (now ~3%).
  %% See if static method improve this.
  global UTILS;

  UTILS.isMatlab = isMatlab();
  
  UTILS.shuffle = @shuffle;
  
  if (UTILS.isMatlab)
	UTILS.linspacea = @linspacea_matlab;
  else
	UTILS.linspacea = @linspacea_octave;
  end
  
  UTILS.reduce = @reduce;
  UTILS.decode = @decode;
  UTILS.arrayToDec = @arrayToDec;
  UTILS.randomIn = @randomIn;

  UTILS.DEBUG = struct('printFlag', @printFlag);
end

function result = shuffle(a)
  new_order = randperm(length(a));
  result = a(new_order);
end

function result = linspacea_octave(a, n)
  result = linspace(a(:, 1), a(:, 2), n);
end

%% Matlab's linspace does not allow array as inputs...
function result = linspacea_matlab(a, n)
  x = linspace(0, 1, n);
  result = (a(:, 2) - a(:, 1)) .* x + a(:, 1);
end

function result = reduce(fn, a, v)
  for i  = a
	v = fn(v, i);
  end
  
  result = v;
end

function h = decode(constraints, l)
  if (l == -1)
	h = @(val) val;
  else
	max_val = 2^l -1;
	h = @(val) dec2val(val, constraints, max_val);
  end
end

%% Convert an individual's decimal values between 0 and max_val to
%% real values (between their corresponding min and max constraints).
function result = dec2val(val, constraints, max_val)
  result = ((val / max_val) .* (constraints(:, 2) - constraints(:, 1))') + constraints(:, 1)';
end

function result = arrayToDec(a)
  dim = size(a);
  result = sum(a .* 2 .^ ((dim(2)-1):-1:0), 2);
end

%% TODO: Specify length
%%       Add leading zeros
function printFlag(f)
  for i = f
	fprintf(1, '%12s (%d)\n', dec2bin(i), i);
  end
end

function result = isMatlab
  result = ~(exist ('OCTAVE_VERSION', 'builtin') > 0);
end

function result = randomIn(interval, N)
  dim = size(interval);
  count = dim(1);
  
  c = interval';
  result = (c(2, :) - c(1, :)) .* rand(N, count) + c(1, :);
end
