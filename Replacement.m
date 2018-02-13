function Replacement
  %SELECTION All selection functions.
	%
	% wheel
	% stochasticUniversalSampling
	% tournament(K), K in [1, N]
	% unbiasedTournament(K), K in [1, N]
	%
	% See also SELECTION>WHEEL, SELECTION>STOCHASTICUNIVERSALSAMPLING,
	% SELECTION>TOURNAMENT, SELECTION>UNBIASEDTOURNAMENT
  
  global REPLACEMENT;

  REPLACEMENT.none = [];
  REPLACEMENT.value = @value;
  REPLACEMENT.old = @old;
  REPLACEMENT.random = @random;
  REPLACEMENT.tournament = @tournament;
end

function result = value(fitness, ~, lambda)
		  %VALUE Replace the worst individuals based on their fitness.

  [~, ordered] = sort(fitness);
  result = ordered(1:lambda);
end

function result = old(~, iteration_appeared_in, lambda)
								%OLD Replace the oldest individuals.
  
  oldest_age = min(iteration_appeared_in);
  oldest = find(iteration_appeared_in == oldest_age);

  N = length(oldest);
  random_index = randi(N, lambda, 1);
  
  result = oldest(random_index);
end


function result = random(fitness, ~, lambda)
								%RANDOM Replace a random individual.
  
  N = length(fitness);
  result = randi(N, lambda, 1);
end

function h = tournament(k)
  if (k < 0)
	error('tournament: K must be in [1, N]');
  end

  h = @(f, ~, l) tournament_(k, f, l);
end

function result = tournament_(k, fitness, lambda)
  %TOURNAMENT Use SELECTION.tournament(K, LAMBDA) to select which
  % individuals to replace.
  %
  % See also SELECTION>TOURNAMENT.

  global SELECTION;
  
  %% I do not have access to SELECTION.tournament_...
  tournament_fn = SELECTION.tournament(k, lambda);

  result = tournament_fn(fitness);
end

