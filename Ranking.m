function Ranking
  global RANKING;

  RANKING.none = [];
  RANKING.linear = @linear;
  RANKING.linear2 = @linear2;
  RANKING.nonLinear = @nonLinear;
end

function h = linear(alpha)
  h = @(r) linearInner_(alpha, r);
end

function result = linearInner_(alpha, ranks)
  N = length(ranks);
  beta = 2 - alpha;
  
  result = (alpha + ((ranks * (beta - alpha)) / (N - 1))) / N;
end

%% t -> [0, 1] is used to compute r -> [0, 2 / (N * (N - 1))];
function h = linear2(t)
  if (t < 0) || (t > 1)
	error('t must be in [0, 1].');
  else
	h = @(r) linear2Inner_(t, r);
  end
end

function result = linear2Inner_(t, ranks)
  N = length(ranks);
  
  r = t * (2 / (N * (N - 1)));
  q = (r * (N - 1) / 2) + 1 / N;

  result = q - ranks * r;
end

function h = nonLinear(alpha)
  if (alpha <= 0) || (alpha >= 1)
	error('alpha must be in ]0, 1[.');
  else
	h = @(r) nonLinearInner_(alpha, r);
  end
end

function result = nonLinearInner_(alpha, ranks)
  %% NOTE: It should be '^ (N - ranks)', with ranks in [1, N]: 1
  %% associated to the worst indiviual, and N to the best.
  %% Instead, as we get ranks in [0, N - 1], with 0 associated to the
  %% best individual, and N - 1 to the worst, it is the same as '^
  %% ranks'.
  %% (
  %%  should be: N - ranks => best: N - N = 0, worst: N - 1
  %%         is: ranks => best: 0, worst: N - 1
  %% )
  result = alpha * (1 - alpha) .^ ranks;
end
