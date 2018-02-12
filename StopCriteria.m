function StopCriteria
							%STOPCRITERIA All stop criteria functions.
							%
							% time
							% threshold(T), T as upper limit
							% variance(V), V as lower limit
							%  
							% See also STOPCRITERIA>THRESHOLD,
							% STOPCRITERIA>VARIANCE
  global STOP_CRITERIA;
  
  %% Time
  STOP_CRITERIA.time = @(f) 0;
  
  STOP_CRITERIA.threshold = @threshold;
  STOP_CRITERIA.variance = @variance;
  STOP_CRITERIA.minMaxRatio = @minMaxRatio;

  %% TODO: Fitness value change rate
end

function h = threshold(t)
  %% TODO: Doc...
  
  h = @(f) thresholdInner_(t, f);
end

function result = thresholdInner_(threshold, fitness)
  %% TODO: Doc...
  
  result = ~isempty(find(fitness >= threshold, 1));
end

function h = variance(v)
  %% TODO: Doc...
  
  h = @(f) varianceInner_(v, f);
end

function result = varianceInner_(variance, fitness)
  %% TODO: Doc...
  
  result = (var(fitness) <= variance);
end

function h = minMaxRatio(r)
  if (r <= 0)
	error('minMaxRatio: R must be > 0');
  end
  
  h = @(f) minMaxRatioInner_(r, f);
end

function result = minMaxRatioInner_(ratio, fitness)
  max_f = max(fitness);
  min_f = min(fitness);

  result = (abs((max_f / min_f) - ratio) <= eps);
end
