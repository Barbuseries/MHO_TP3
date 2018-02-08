function Selection
  global SELECTION;
  
  SELECTION.wheel = @wheel;
  SELECTION.stochasticUniversalSampling = @stochasticUniversalSampling;
  SELECTION.tournament = @tournament;
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

function h = tournament(k)
  if (k < 1)
	error('k must be in [1, N]');
  end
  
  h = @(p) tournamentInner_(k, p);
end

function result = tournamentInner_(k, probabilities)
  N = length(probabilities);

  if (k > N)
	error('k must be in [1, N]');
  end

  random_indices = randi(N, N, k);
  
  BY_COLUMN = 2;
  [~, rel_max_indices] = max(probabilities(random_indices), [], BY_COLUMN);
  max_indices = (rel_max_indices - 1) * N + (1:N)';
  
  result = random_indices(max_indices);
end
