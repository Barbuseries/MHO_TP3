%% TODO: - Matlab-like function doc.
%%       - Find a way to automatically reload includes (maybe run
%%         <include> could work...).

%% Includes
Problem;

config = GA.defaultConfig();
config.N = 100;
config.l = 52;

%% p1 = Problem.rosenbrock();
%% config.G_max = 1000;
%% [result1, history1] = p1.optimize(config);

%% disp(result1);
%% disp(p1.objective_fn(result1(1), result1(2)));

%% GA.showHistory(p1, history1, -1);

%% p1 = Problem.griewank();
%% config.G_max = 500;
%% [result1, history1] = p1.optimize(config);

%% disp(result1);
%% disp(p1.objective_fn(result1(1), result1(2)));

%% GA.showHistory(p1, history1, -1);


p2 = Problem.TOTO();
config.N = 10;
config.G_max = 1000;
config.Pc = 0.8;
config.Pm = 0.01;
[result2, history2] = p2.optimize(config);

disp(result2);
disp(p2.objective_fn(result2));

GA.showHistory(p2, history2, -1);
