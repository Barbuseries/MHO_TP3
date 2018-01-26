%% Includes
GA;

%% TODO?: As we already have to type Problem.<problem>(), maybe we
%% could change their definition to call optimize directly (instead of
%% Problem.<problem>().optimize(config) => Problem.<problem>(config)).
function export = Problem
  export.rosenbrock = @rosenbrock_problem;
  export.TOTO = @TOTO_problem;
end

function result = rosenbrock_problem
  result.objective_fn = @Rosenbrock;
  result.fitness_fn = @(p) @Rosenbrock(p(:, 1), p(:, 2));
  result.constraints = [[0, 2]
					    [0, 3]];

  result.optimize = optimize(result, 1);
end

function result = TOTO_problem
  result.objective_fn = @TOTO;
  result.fitness_fn = @(p) @TOTO(p(:, 1));
  result.constraints = [[-1, 2]];

  result.optimize = optimize(result, 1);
end

function result = Rosenbrock(x, y)
  a = x .* x;
  b = y - a;

  result = -((1 - a) + 100 * (b .* b));
end

function result = TOTO(x)
  result = x .* sin(10 * pi .* x) + 2;
end

%% FIXME: Optimizing got slower (~0.5s) once this currying took place.
%% See if we wish to keep this "clean" syntax or not.
%% NOTE about FIXME: The slowness seems to have disappeared after
%% restarting octave...
function result = optimize(problem, maximize)
  if (maximize == 1)
	result = @(config) GA.maximize(problem().fitness_fn, problem().constraints, config);
  else
	result = @(config) GA.minimize(problem().fitness_fn, problem().constraints, config);
  end  
end
