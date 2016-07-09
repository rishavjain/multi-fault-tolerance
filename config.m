function [ params ] = config()

params = {};

%% agents parameters
params.agents.num = 10;
params.agents.speed = 40;
params.agents.commrange = 2;

%% environment parameters
params.env.path = [0 0;
    20 0;
    20 15;
    -15 15;
    -15 -15;
    20 -15;
    20 -35;
    0 -35;
%     10 -25;
%     0 -25;
%     0 -35;
    ]';

params.env.inflationSize = 5;

%% simulation parameters
params.sim.maxtime = 6000;         % maximum time for simulation
params.sim.timestep = 0.05;     % time step

%% figure parameters
params.fig1.num = 1000;
params.fig1.subplot = [1 3];
params.fig1.env = [2 3];
params.fig1.envAxisPadding = 10;

%% log parameters
% params.log = {};
params.log.fileId = 1; % 1 for screen output
params.log.level = 1;

%% code
addpath(genpath('.'));

params.openFileIds = [];

params.fig1handle = resetfigure(params);

end
