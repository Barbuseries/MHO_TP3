function StopCriteria
							%STOPCRITERIA All stop criteria functions.
							%
							% time
							% threshold(T), T as upper limit
							% variance(V), V as lower limit
							% minMaxRatio(R)
							% meanChangeRate(R), R as lower limit
							%
							% See also STOPCRITERIA>THRESHOLD,
							% STOPCRITERIA>VARIANCE
  global STOP_CRITERIA;
  
  %% Time
  STOP_CRITERIA.time = @(f) 0;
  
  STOP_CRITERIA.threshold = @threshold;
  STOP_CRITERIA.variance = @variance;
  STOP_CRITERIA.minMaxRatio = @minMaxRatio;

  STOP_CRITERIA.meanChangeRate = @meanChangeRate;
end

function h = threshold(t)
  %% TODO: Doc...
  
  h = @(f, old_f) thresholdInner_(t, f);
end

function result = thresholdInner_(threshold, fitness)
  %% TODO: Doc...
  
  result = ~isempty(find(fitness >= threshold, 1));
end

function h = variance(v)
  %% TODO: Doc...
  
  h = @(f, old_f) varianceInner_(v, f);
end

function result = varianceInner_(variance, fitness)
  %% TODO: Doc...
  
  result = (var(fitness) <= variance);
end

function h = minMaxRatio(r)
  %% TODO: Doc...
  
  if (r <= 0)
	error('minMaxRatio: R must be > 0');
  end
  
  h = @(f, old_f) minMaxRatioInner_(r, f);
end

function result = minMaxRatioInner_(ratio, fitness)
  %% TODO: Doc...
  
  max_f = max(fitness);
  min_f = min(fitness);

  result = (abs((max_f / min_f) - ratio) <= eps);
end

function h = meanChangeRate(cr)
  %% TODO: Doc...
  
  h = @(f, old_f) meanChangeRateInner_(cr, f, old_f);
end

function result = meanChangeRateInner_(change_rate, fitness, old_fitness)
  %% TODO: Doc...
  
  if (length(old_fitness) == 0)
	result = 0;
	return;
  end
  
  mean_f = mean(fitness);
  mean_old_f = mean(old_fitness);

  rate = abs((mean_f - mean_old_f) / mean_old_f);
  result = (rate <= change_rate);
end
