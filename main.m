%% Includes
Problem;

config = GA.defaultConfig();
config.l = 52;

p1 = Problem.rosenbrock();
config.G_max = 500;
[result1, history1] = p1.optimize(config);

disp(result1);
disp(p1.objective_fn(result1(1), result1(2)));


p2 = Problem.TOTO();
config.G_max = 100;
[result2, history2] = p2.optimize(config);

disp(result2);
disp(p2.objective_fn(result2));

%% AG_plotHistory(history);

%% x = linspacea(constraints(1, :), 1000);
%% y = linspacea(constraints(2, :), numel(x));

%% [xx, yy] = meshgrid(x, y);
%% z = Rosenbrock(xx, yy)';

%% mesh(x, y, z);
