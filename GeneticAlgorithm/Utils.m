function Utils
  global UTILS;

  UTILS.isMatlab = isMatlab();
  
  UTILS.shuffle = @shuffle;
  
  if (UTILS.isMatlab)
	UTILS.linspacea = @linspacea_matlab;
	UTILS.select = @select_matlab;
  else
	UTILS.linspacea = @linspacea_octave;
	UTILS.select = @select_octave;
  end
  
  UTILS.reduce = @reduce;
  UTILS.decode = @decode;
  UTILS.arrayToDec = @arrayToDec;
  UTILS.randomIn = @randomIn;
  UTILS.evalFn = @evalFn;
  UTILS.tourLength = @tourLength_;
  UTILS.randUnique = @randUnique_;
  UTILS.randUniqueS = @randUniqueS_;
  
  UTILS.DEBUG = struct('printFlag', @printFlag, ...
					   'assertIntegrity', @assertIntegrity_);
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

function h = decode(l)
  if (l == -1)
	h = @(t) t;
  else
    error('binary representation is not yet implemented (and probably never will)');
  end
end

%% Convert an individual's decimal values between 0 and max_val to
%% real values (between their corresponding min and max constraints).
function result = dec2val(val, constraints, max_val)
  result = ((val / max_val) .* (constraints(:, 2) - constraints(:, 1))') + constraints(:, 1)';
end

function result = arrayToDec(a)
  dim = size(a);
  l = dim(2);
  result = sum(a .* 2 .^ ((l-1):-1:0), 2);
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

function result = evalFn(fn, val_array)
  %% TODO: Uncomment when this works in 3D.
  %BY_COLUMN = 2;
  %to_var_arg = num2cell(val_array', BY_COLUMN);
  %result = fn(to_var_arg{:});
  
  result = fn(val_array);
  result = reshape(result, length(result), 1, 1);
end

%% TODO: Find a better name than 'select'.
%% NOTE: Just so you know:
%%         - the matlab version was found first
%%         - it is 10% faster than the octave one (on matlab)
%%         - the octave version is 2 times faster on octave (than the
%%           matlab version on octave)
function result = select_matlab(probabilities, values)
  cumulative_sum = cumsum(probabilities);
  
  %% NOTE: I did not find a way to 'find' (pun intended) in a matrix
  %% row-wise (meaning that I want, for each row, the result of the
  %% find for this row (it must be because matrices row and column
  %% sizes must be constant)) without introducing an explicit
  %% loop. Therefore, instead of using find, I use max which returns
  %% (as well as the value) the index of the first occurrence of one
  %% (which is the max value). To make it operate on rows, the second
  %% parameter is ignored and I must give it the dimension to operate
  %% on (BY_ROW).
  %% NOTE(@perf): Replacing the for loop by max made this function at
  %% least 20 times faster. There may be a way to use find here in the
  %% end, but I haven't found any.
  %% NOTE(@perf): This is the bottleneck (of an already optimized
  %% script).
  BY_ROW = 2;
  [~, result] = max(cumulative_sum >= values, [], BY_ROW);
end

function result = select_octave(probabilities, values)
  cumulative_sum = cumsum(probabilities);
  
  %% NOTE(@perf): This is the bottleneck (of an already optimized
  %% script).
  %% This is a cumulative array, as we are looking for the first i,
  %% such as cumul(i) >= v, every i after the first one that validates
  %% the predicate also validates it.
  %% So there are (N + 1 - i) ones (because i starts at 1 and not 0).
  %% And we need i.
  BY_ROW = 2;
  result = (length(probabilities) + 1) - sum(cumulative_sum >= values, BY_ROW);
end

function h = tourLength_(cities)
  [N, d] = size(cities);

  %% TODO: Improve this (remove unneeded transpositions)
  h = @(t) tourLengthInner_(permute(reshape(cities(t', :)', d, N, []), [2, 1, 3]));
end

function result = tourLengthInner_(cities)
  BY_ROW = 2;

  %% Also compute the distance between the last city and the first one.
  complete_tour = [cities; cities(1, :, :)];
  all_distances = sqrt(sum((complete_tour(2:end, :, :) - complete_tour(1:end-1, :, :)) .^2, BY_ROW));
  result = sum(all_distances);
end

function result = randUnique_(M, N, k)
% RANDUNIQUE_(N, M, K) Return an N by K matrix containing
% K unique values in 1:M per row.
  
  BY_ROW = 2;
  
  [~, indices] = sort(rand(N, M), BY_ROW);
  result = indices(:, 1:k);
end

function result = randUniqueS_(M, N, k)
% RANDUNIQUES_(N, M, K) Return an N by K matrix containing
% K sorted unique values in 1:M per row.
  
  BY_ROW = 2;
  result = sort(randUnique_(N, M, k), BY_ROW);
end

function assertIntegrity_(tours, city_count)
  BY_ROW = 2;
  assert(all(all(ismember(tours, 1:city_count), BY_ROW)));
end
