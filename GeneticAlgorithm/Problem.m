function Problem
  global PROBLEM;
  
  PROBLEM.generate = @generate_;
end

function [result] = generate_(N, constraints)
  global UTILS;
 
  
  result = UTILS.randomIn(constraints, N);
end

