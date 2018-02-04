function Ranking
  global RANKING;

  RANKING.none = [];
  RANKING.linear = @linear;
end

function h = linear(alpha, beta)
  h = @(r) linearInner_(alpha, beta, r);
end

function result = linearInner_(alpha, beta, ranks)
  N = length(ranks);
  
  result = (alpha + (((ranks - 1) * (beta - alpha)) / (N - 1))) / N;
end
