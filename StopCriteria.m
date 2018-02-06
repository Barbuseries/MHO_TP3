function StopCriteria
  global STOP_CRITERIA;
  
  %% Time
  STOP_CRITERIA.time = @(f) 0;
  
  STOP_CRITERIA.threshold = @fitnessThreshold;
  STOP_CRITERIA.variance = @fitnessVariance;

  %% TODO: Fitness value change rate
end

function h = fitnessThreshold(t)
  h = @(f) fitnessThresholdInner_(t, f);
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
