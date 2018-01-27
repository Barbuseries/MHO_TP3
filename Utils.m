function export = Utils
  export.shuffle = @shuffle;
  export.linspacea = @linspacea;
  export.reduce = @reduce;
  export.dec2val = @dec2val;
  export.decode = @decode;

  export.DEBUG = struct('print_flag', @print_flag);
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

%% TODO: Specify length
%%       Add leading zeros
function print_flag(f)
  for i = f
	fprintf(1, '%12s (%d)\n', dec2bin(i), i);
  end
end
