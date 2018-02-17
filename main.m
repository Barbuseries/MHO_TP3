%% Includes
Utils;         global UTILS;

Replacement;   global REPLACEMENT;
Ranking;       global RANKING;
FitnessChange; global FITNESS_CHANGE;
Selection;     global SELECTION;
Crossover;     global CROSSOVER;
Mutation;      global MUTATION;
StopCriteria;  global STOP_CRITERIA;
Clamp;         global CLAMP;
Ga;            global GA;
Problem;       global PROBLEM;

PROFILING = 0;

if (PROFILING)
  profile off;
  profile clear;
  profile on;
end

%% Configuration
p = PROBLEM.rosenbrock();

config = GA.defaultConfig();
config.N = 100; %% If steady state is off, N must be even. Otherwhise, it does not matter.
config.G_max = 1000;
config.l = -1; %% If to to -1, real encoding. Possible values: -1 or in [1, 53] 
config.lambda = -1; %% If set to -1, no steady state. Possible values: [-1, 1, 2]
%% config.ranking_fn = RANKING.nonLinear(0.99);
config.fitness_change_fn = FITNESS_CHANGE.none;
config.selection_fn = SELECTION.unbiasedTournament(2);
config.crossover_fn = CROSSOVER.blend(1);
config.mutation_fn = MUTATION.uniform;
config.stop_criteria_fn = STOP_CRITERIA.threshold(p.threshold_r, p.threshold);
config.clamp_fn = CLAMP.default;
%% config.replacement_fn = REPLACEMENT.value; %% Needs to be set if config.lambda is ~= 0
[r, h] = p.optimize(config);

disp('Best individual at last iteration, and its fitness:')
disp(r);
disp(UTILS.evalFn(p.objective_fn, r));

disp('Best indiviual across all iterations, and its fitness:')
disp(h.very_best.value);
disp(UTILS.evalFn(p.objective_fn, r));

GA.showHistory(p, h, -1);

if (PROFILING)
  if (UTILS.isMatlab)
	profile viewer;
  else
	profshow;
  end
end
