addpath(genpath('.'));
params = initialize();

params.agents.num = 20;

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

path = params.env.path;
hPath = patchline(path(1,:), path(2,:), 'LineWidth', 4, 'EdgeColor', 'g', 'EdgeAlpha', 0.2);
    
envRegions = inflate_path(params);

for iRegion = 1:length(envRegions)    
    envRegions(iRegion).draw_polygon();
end

[partitions, vPartitions, mapping] = create_partitions(params, envRegions);

figure(params.fig.num);
for iPartition = 1:length(partitions)
    partition = cell2mat(partitions(iPartition));
    plot(partition(2:3,1), partition(2:3,2), 'k');
    plot(partition(4:5,1), partition(4:5,2), 'k');
end

finish(params)
