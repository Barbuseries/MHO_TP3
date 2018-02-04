function Ranking
  global RANKING;

  RANKING.none = [];
  RANKING.linear = @linear;
  RANKING.linear2 = @linear2;
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
	error('t mus be in [0, 1].');
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
