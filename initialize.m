function [ params ] = initialize()

addpath('regions')

params = {};
params.log = {};

params.openFileIds = [];

params.log.fileId = 1; % 1 for screen output
params.log.level = 1;

end
