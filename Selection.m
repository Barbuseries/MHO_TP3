function Selection
	%SELECTION All selection functions.
	%
	% wheel
	% stochasticUniversalSampling
	% tournament(K), K in [1, N]
	% unbiasedTournament(K), K in [1, N]
	%
	% See also SELECTION>WHEEL, SELECTION>STOCHASTICUNIVERSALSAMPLING,
	% SELECTION>TOURNAMENT, SELECTION>UNBIASEDTOURNAMENT
  
  global SELECTION;
  
  SELECTION.wheel = @wheel;
  SELECTION.stochasticUniversalSampling = @stochasticUniversalSampling;
  SELECTION.tournament = @tournament;
  SELECTION.unbiasedTournament = @unbiasedTournament;
end

function result = wheel(probabilities)
 %WHEEL For as many times as there are elements in PROBABILITIES, find
 % the first index for which cumsum(PROBABILITIES) >= rand.
 %
 % See also SELECTION>STOCHASTICUNIVERSALSAMPLING.
  
  global UTILS;

  %% We need to select as many individuals as there already are.
  wheel = rand(length(probabilities), 1);
  
  result = UTILS.select(probabilities, wheel);
end

function result = stochasticUniversalSampling(probabilities)
%STOCHASTICUNIVERSALSAMPLING Same as a wheel selection, but instead of
% generating N random numbers, use N equidistant pointers which are
% used as thresholds (the first pointer position is a random number in
% [0, 1/N]), with N being the number of elements in PROBABILITIES.
%
% See also SELECTION>WHEEL.
  
  global UTILS;
  
  N = length(probabilities);

  delta = 1/N; %% Distance between two pointers
  start_pos = delta * rand();
  pointers = delta * (0:(N-1)) + start_pos; %% Generate equidistant pointers starting at start_pos

  %% Find the first index for which
  %% cumsum(probabilities)(i) >= pointers(i)
  result = UTILS.select(probabilities, pointers');
end

function h = tournament(k)
	   %TOURNAMENT Return a function that produces TOURNAMENT_(K,
	   % PROBABILITIES) when given PROBABILITIES.
	   %   H = TOURNAMENT(K)
	   %
	   % 1 <= K <= N, with N = length(PROBABILITIES)
	   %
	   % See also SELECTION>UNBIASEDTOURNAMENT, SELECTION>TOURNAMENT_.
  
  if (k < 1)
	error('K must be in [1, N]');
  end
  
  h = @(p) tournament_(k, p);
end

function result = tournament_(k, probabilities)
%TOURNAMENT_ For as many times as there are elements in PROBABILITIES,
% select K elements in PROBABILITIES at random and keep the index of
% the maximum value.
%
% See also SELECTION>TOURNAMENT, SELECTION>UNBIASEDTOURNAMENT.
  
  N = length(probabilities);

  if (k > N)
	error('K must be in [1, N]');
  end

  %% For each selection, select  which k elements we compare.
  random_indices = randi(N, N, k);

  %% For each selection, the index of the maximum value (in random_indices)
  max_indices = tournamentSelect_(random_indices, probabilities);
  result = random_indices(max_indices);
end

function h = unbiasedTournament(k)
%UNBIASEDTOURNAMENT Return a function that produces UNBIASEDTOURNAMENT_(K,
% PROBABILITIES) when given PROBABILITIES.
%   H = UNBIASEDTOURNAMENT(K)
%
% 1 <= K <= N, with N = length(PROBABILITIES)
%
% See also SELECTION>TOURNAMENT, SELECTION>UNBIASEDTOURNAMENT_.
  
  if (k < 1)
	error('K must be in [1, N]');
  end
  
  h = @(p) unbiasedTournament_(k, p);
end

function result = unbiasedTournament_(k, probabilities)
 %UNBIASEDTOURNAMENT_ Create K permutations of probabilities. At each
 % index, compare the K permutations and keep the index of the maximum
 % associated element in PROBABILITIES.
 %
 % See also SELECTION>UNBIASEDTOURNAMENT, SELECTION>TOURNAMENT.
  
  N = length(probabilities);

  if (k > N)
	error('K must be in [1, N]');
  end

  permutations = zeros(k, N);
  for i = 1:k
	permutations(i, :) = randperm(N);
  end

  %% Comparing the permutations column-wise is the same as transposing
  %% them and comparing them row-wise (which is the same as a
  %% tournament selection).
  permutations = permutations';
  max_indices = tournamentSelect_(permutations, probabilities);
  
  result = permutations(max_indices);
end

function result = tournamentSelect_(random_indices, probabilities)
  N = length(probabilities);
  
  %% Find the indices of the maximum values row-wise.
  BY_ROW = 2;
  [~, rel_max_indices] = max(probabilities(random_indices), [], BY_ROW);

  %% max returns the index relative to the row (not the whole matrix)
  %% i.e, 1 correponds to the first column, no matter which row we are
  %% in.
  %% And I want 1 to only refer to the first column in the first row.
  result = relatviveToExactIndex_(rel_max_indices, N);
end

function result = relatviveToExactIndex_(ind, N)
  %% ind is the relative index of the column (in 1:N).
  %% What we want is its exact location in the matrix.
  %% We know the matrix has N rows and that matrix indexing is
  %% column-wise.
  %% i.e, 1 refers to (1, 1), 2 to (1, 2), ..., N + 1 to (2, 1), ...
  result = (ind - 1) * N + (1:N)';
end
