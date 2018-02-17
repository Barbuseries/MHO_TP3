function Problem
  global PROBLEM;
  
  PROBLEM.rosenbrock = @rosenbrockProblem;
  PROBLEM.griewank = @griewankProblem;
  PROBLEM.TOTO = @TOTOProblem;
end

function result = rosenbrockProblem
  result.objective_fn = @Rosenbrock;
  result.fitness_fn = @Rosenbrock;
  result.constraints = [[0, 2]
					    [0, 3]];
  result.limit = 2.0025;
  result.threshold = 2.002;
  result.threshold_r = @gt;

  result.optimize = optimize(result, 1);
end

function result = griewankProblem
  result.objective_fn = @Griewank;
  result.fitness_fn = @Griewank;
  result.constraints = [[-30, 30]
					    [-30, 30]];
  result.limit = 0;
  result.threshold = 10^-4;
  result.threshold_r = @lt;

  result.optimize = optimize(result, 0);
end

function result = TOTOProblem
  result.objective_fn = @TOTO;
  result.fitness_fn = @TOTO;
  result.constraints = [[-1, 2]];
  
  result.limit = 3.8503;
  result.threshold = 3.85;
  result.threshold_r = @gt;

  result.optimize = optimize(result, 1);
end

function result = Rosenbrock(x, y)
  a = x .* x;
  b = y - a;

  result = -((1 - a) + 100 * (b .* b));
end

function result = Griewank(x, y)
  result = (((x .* x) + (y .* y)) / 4000) - cos(x) .* cos(y / sqrt(2)) + 1;
end

function result = TOTO(x)
  result = x .* sin(10 * pi .* x) + 2;
end

function result = optimize(problem, maximize)
    global GA;
  
    result = @(config) GA.optimize(maximize, problem.objective_fn, problem.fitness_fn, problem.constraints, config);
end
