%% TODO: - Matlab-like function doc.

%% Includes
Crossover; global CROSSOVER;
Mutation;  global MUTATION;
Utils;     global UTILS;
Ga;        global GA;
Problem;   global PROBLEM;

PROFILING = 1;

if (PROFILING)
  profile off;
  profile clear;
  profile on;
end

config = GA.defaultConfig();
config.N = 100;
config.l = 52;
config.crossover_fn = CROSSOVER.uniform(0.5);

% % p1 = PROBLEM.rosenbrock();
% % config.N = 200;
% % config.G_max = 1500;
% % config.crossover_fn = CROSSOVER.multiPoint(10);
% % [result1, history1] = p1.optimize(config);
% % 
% % disp(result1);
% % disp(p1.objective_fn(result1(1), result1(2)));
% % 
% % disp(history1.very_best.value);
% % 
% % GA.showHistory(p1, history1, -1);

% % p1 = PROBLEM.griewank();
% % config.N = 1000;
% % config.G_max = 1000;
% % decode1 = UTILS.decode(p1, config);
% % %%config.crossover_fn = CROSSOVER.uniform(@(x, y) (x ./ (x + y)), @(x) p1.fitness_fn(decode1(x)));
% % [result1, history1] = p1.optimize(config);
% % 
% % disp(result1);
% % disp(p1.objective_fn(result1(1), result1(2)));
% % 
% % disp(history1.very_best.value);
% % 
% % GA.showHistory(p1, history1, -1);


p2 = PROBLEM.TOTO();
config.N = 10;
config.G_max = 1000;
config.Pc = 0.8;
config.Pm = 0.01;

decode2 = UTILS.decode(p2, config);
config.crossover_fn = CROSSOVER.uniform(@(x, y) (x ./ (x + y)), @(x) p2.fitness_fn(decode2(x)));
%% config.crossover_fn = CROSSOVER.singlePoint;

[result2, history2] = p2.optimize(config);

disp(result2);
disp(p2.objective_fn(result2));

disp(history2.very_best.value);

GA.showHistory(p2, history2, -1);


if (PROFILING)
  if (UTILS.isMatlab)
	profile viewer;
  else
	profshow;
  end
end
