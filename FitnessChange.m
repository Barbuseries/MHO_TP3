function FitnessChange
  global FITNESS_CHANGE;

  FITNESS_CHANGE.none = @(f) f;
  FITNESS_CHANGE.offset = @offset;
  FITNESS_CHANGE.linearScale = @linearScale;
  FITNESS_CHANGE.sigmaTruncation = @sigmaTruncation;
end

%% NOTE: This is not a standard function. I just used this before
%% implementing any other method so I could handle negative fitness
%% values.
function result = offset(fitness)
  min_fitness = min(fitness);
  
  %% Remove negative fitness and a little more, so their relative
  %% fitness is not 0 (not selectable).
  if (min_fitness < 0)
	result = fitness - 2 * min(fitness);
  else
	result = fitness;
  end
end

function result = linearScale(fitness)
  f_mean = mean(fitness);
  f_max = max(fitness);
  f_min = min(fitness);

  a = f_mean / (f_mean - f_min);
  b = (f_mean * f_min) / (f_max - f_min);

  result = a * fitness + b;
end

function h = sigmaTruncation(c)
  if (c < 1) || (c > 5)
	error("c must be in [1, 5]");
  else
	h = @(f) sigmaTruncationInner_(c, f);
  end
end

function result = sigmaTruncationInner_(c, fitness)
  sigma = std(fitness);

  result = fitness - (mean(fitness) - c * sigma);
  result(result < 0) = 0;
end
