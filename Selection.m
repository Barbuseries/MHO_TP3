function Selection
  global SELECTION;
  
  SELECTION.wheel = @wheel;
  SELECTION.stochasticUniversalSampling = @stochasticUniversalSampling;
  SELECTION.tournament = @tournament;
  SELECTION.unbiasedTournament = @unbiasedTournament;
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

  max_indices = tournamentSelect_(random_indices, probabilities);
  result = random_indices(max_indices);
end

function h = unbiasedTournament(k)
  h = @(p) unbiasedTournamentInner_(k, p);
end

function result = unbiasedTournamentInner_(k, probabilities)
  N = length(probabilities);

  if (k > N)
	error('k must be in [1, N]');
  end

  permutations = zeros(k, N);
  for i = 1:k
	permutations(i, :) = randperm(N);
  end

  %% TODO: Explain!
  permutations = permutations';
  max_indices = tournamentSelect_(permutations, probabilities);
  
  result = permutations(max_indices);
end

function result = tournamentSelect_(random_indices, probabilities)
  N = length(probabilities);
  
  %% TODO: Explain!
  BY_ROW = 2;
  [~, rel_max_indices] = max(probabilities(random_indices), [], BY_ROW);
  result = relatviveToExactIndex_(rel_max_indices, N);
end

function result = relatviveToExactIndex_(ind, N)
  result = (ind - 1) * N + (1:N)';
end
