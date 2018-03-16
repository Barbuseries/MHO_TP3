folder = fileparts(which(mfilename)); 
addpath(genpath(folder))

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
cities = PROBLEM.generate(9, [[0, 10]
                              [0, 10]]);
GA.plot(cities, false);
drawnow;

config = GA.defaultConfig();
config.N = 100;
config.G_max = 250;
config.Pc = 0.8;
config.Pm = 0.01;
%% config.l = -1; %% If set to -1, real encoding. Possible values: -1 or in [1, 53] 
%%config.fitness_change_fn = FITNESS_CHANGE.none;
config.selection_fn = SELECTION.unbiasedTournament(2);
config.crossover_fn = CROSSOVER.partial;
config.mutation_fn = MUTATION.inverse;
%% config.stop_criteria_fn = STOP_CRITERIA.threshold(p.threshold_r, p.threshold);
%% config.clamp_fn = CLAMP.default;

length_fn = UTILS.tourLength(cities);

[r, h] = GA.optimize(0, length_fn, length_fn, cities, config);
GA.plot(cities(h.very_best.value, :), true);

%% disp('Best individual at last iteration, and its fitness:')
%% disp(r);
%% disp(UTILS.evalFn(p.objective_fn, r));

%% disp('Best indiviual across all iterations, and its fitness:')
%% disp(h.very_best.value);
%% disp(UTILS.evalFn(p.objective_fn, r));

%% GA.showHistory(p, h, -1);

if (PROFILING)
  if (UTILS.isMatlab)
	profile viewer;
  else
	profshow;
  end
end
