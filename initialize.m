function [ params ] = initialize()

%% configuration parameters
params = {};

params.fig.num = 1000;

% params.log = {};
params.log.fileId = 1; % 1 for screen output
params.log.level = 1;

%% code initialize
params.openFileIds = [];

addpath(genpath('.'));
resetfigure(params);

end
