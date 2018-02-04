function Selection
  global SELECTION;
  
  SELECTION.wheel = @wheel;
  SELECTION.stochasticUniversalSampling = @stochasticUniversalSampling;
end

function result = wheel(probabilities)
  global UTILS;

  %% We need to select as many individuals as there already are.
  wheel = rand(length(probabilities), 1);
  
  result = UTILS.select(probabilities, wheel);
end

function result = stochasticUniversalSampling(probabilities)
  global UTILS;
  
  N = length(probabilities);
  
  %% TODO: Explain!
  delta = 1/N;
  start_pos = delta * rand();
  pointers = delta * (0:(N-1)) + start_pos;

  result = UTILS.select(probabilities, pointers');
end
