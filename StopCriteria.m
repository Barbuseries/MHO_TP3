function StopCriteria
  global STOP_CRITERIA;
  
  %% Time
  STOP_CRITERIA.time = @(f) 0; %% None
  
  STOP_CRITERIA.threshold = @fitnessThreshold; %% THRESHOLD (upper) limit
  STOP_CRITERIA.variance = @fitnessVariance; %% VARIANCE (lower) limit

  %% TODO: Fitness value change rate
end

function h = fitnessThreshold(threshold)
  h = @(f) fitnessThresholdInner_(threshold, f);
end

function result = fitnessThresholdInner_(threshold, fitness)
  result = ~isempty(find(fitness >= threshold, 1));
end

function h = fitnessVariance(variance)
  h = @(f) fitnessVarianceInner_(variance, f);
end

function result = fitnessVarianceInner_(variance, fitness)
  result = (var(fitness) <= variance);
end
