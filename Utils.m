function export = Utils
  %% NOTE/TODO(@perf): Utils is evaluated in many places, this an overhead of
  %% ~10%.
  %% Making export persistent removes most of this overhead (now ~3%).
  %% See if static method improve this.
  persistent export;
  
  if (isempty(export))
	export.shuffle = @shuffle;
	export.linspacea = @linspacea;
	export.reduce = @reduce;
	export.dec2val = @dec2val;
	export.decode = @decode;
	export.arrayToDec = @arrayToDec;

	export.isMatlab = isMatlab();

	export.DEBUG = struct('printFlag', @printFlag);
  end
end

function result = shuffle(a)
  new_order = randperm(length(a));
  result = a(new_order);
end

function result = linspacea(a, n)
  result = linspace(a(:, 1), a(:, 2), n);
end

function result = reduce(fn, a, v)
  for i  = a
	v = fn(v, i);
  end
  
  result = v;
end

%% Convert an individual's decimal values between 0 and (2**l -1) to
%% real values (between their corresponding min and max constraints).
%% TODO: Use l == -1 as 'no encoding took place'.
function result = dec2val(val, constraints, l)
  max_val = 2**l-1;
  result = ((val / max_val) .* (constraints(:, 2) - constraints(:, 1))') + constraints(:, 1)';
end

function h = decode(problem, config)
  h = @(val) dec2val(val, problem.constraints, config.l);
end

function result = arrayToDec(a)
  dim = size(a);
  result = sum(a .* 2 .** ((dim(2)-1):-1:0), 2);
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
