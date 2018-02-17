function FitnessChange
		   %FITNESSCHANGE All fitness change functions.
		   %
		   % none
		   % linearScale
		   % sigmaTruncation(C), C in [1, 5]
		   %
		   % See also FITNESSCHANGE>LINEARSCALE,
		   % FITNESSCHANGE>SIGMATRUNCATION
  global FITNESS_CHANGE;

  FITNESS_CHANGE.none = @(f) f;
  FITNESS_CHANGE.linearScale = @linearScale;
  FITNESS_CHANGE.sigmaTruncation = @sigmaTruncation;
end

function result = linearScale(fitness)
  %LINEARSCALE Linearly scales FITNESS.
  
  f_mean = mean(fitness);
  f_max = max(fitness);
  f_min = min(fitness);

  a = f_mean / (f_mean - f_min);
  b = (f_mean * f_min) / (f_max - f_min);

  result = a * fitness + b;
end

function h = sigmaTruncation(c)
%SIGMATRUNCATION Return a function that produces sigmaTruncation_(C,
% FITNESS) when given FITNESS.
%
% See also FITNESSCHANGE>SIGMATRUNCATION_.
  
  if (c < 1) || (c > 5)
	error('c must be in [1, 5].');
  else
	h = @(f) sigmaTruncation_(c, f);
  end
end

function result = sigmaTruncation_(c, fitness)
%SIGMATRUNCATION_ FITNESS' = FITNESS - (MEAN(FITNESS) - c * STD(FITNESS))
% If FITNESS' ends up negative, it is clamped up to 0.

  sigma = std(fitness);

  result = fitness - (mean(fitness) - c * sigma);
  result(result < 0) = 0;
end
