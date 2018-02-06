%% TODO: - Matlab-like function doc.

%% Includes
Utils;         global UTILS;

Ranking;       global RANKING;
FitnessChange; global FITNESS_CHANGE;
Selection;     global SELECTION;
Crossover;     global CROSSOVER;
Mutation;      global MUTATION;
StopCriteria;  global STOP_CRITERIA;
Ga;            global GA;
Problem;       global PROBLEM;

PROFILING = 0;

if (PROFILING)
  profile off;
  profile clear;
  profile on;
end

p = PROBLEM.rosenbrock();

config = GA.defaultConfig();
config.N = 1000;
config.G_max = 1000;
config.l = -1;
config.ranking_fn = RANKING.nonLinear(0.99);
config.fitness_change_fn = FITNESS_CHANGE.none;
config.selection_fn = SELECTION.stochasticUniversalSampling;
config.crossover_fn = CROSSOVER.blend();
config.mutation_fn = MUTATION.uniform;
config.stop_criteria_fn = STOP_CRITERIA.threshold(1.99);
[r, h] = p.optimize(config);

disp(r);
disp(UTILS.evalFn(p.objective_fn, r));

disp(h.very_best.value);

GA.showHistory(p, h, -1);

if (PROFILING)
  if (UTILS.isMatlab)
	profile viewer;
  else
	profshow;
  end
end
