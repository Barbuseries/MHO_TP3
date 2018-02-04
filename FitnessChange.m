function FitnessChange
  global FITNESS_CHANGE;

  FITNESS_CHANGE.none = @(f) f;
  FITNESS_CHANGE.linearScale = @linearScale;
  FITNESS_CHANGE.sigmaTruncation = @sigmaTruncation;
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
