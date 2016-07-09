function draw_env( params, envRegions, partitions, agents, action )
%DRAW_ENV Summary of this function goes here
%   Detailed explanation goes here

persistent hPath hRegions hPartitions;

if strcmp(action, 'new')
    %%% setting up the subplot for environment
    figure(params.fig1.num);
    subplot(params.fig1.subplot(1), params.fig1.subplot(2), params.fig1.env);
    
    hold on;
    axis equal;
    grid on;
    grid minor;
    box on;
    
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    
    ntitle('Environment Map', 'Location', 'north', 'FontSize', 14);
    
    %%% drawing the path
    path = params.env.path;
    hPath = patchline(path(1,:), path(2,:), 'LineWidth', 4, 'EdgeColor', 'green', 'EdgeAlpha', 0.2);
    
    minX = Inf;
    maxX = -Inf;
    minY = Inf;
    maxY = -Inf;
    
    %%% drawing the regions (only the upper and lower boundaries)
    hRegions = zeros(length(envRegions), 2);
    for iRegion = 1:length(envRegions)
        hRegions(iRegion, :) = envRegions(iRegion).draw_polygon();
        
        %%% calculating the size the of environment to set the axes
        if max(envRegions(iRegion).polygon(:,1)) > maxX
            maxX = max(envRegions(iRegion).polygon(:,1));
        end
        if max(envRegions(iRegion).polygon(:,2)) > maxY
            maxY = max(envRegions(iRegion).polygon(:,2));
        end
        if min(envRegions(iRegion).polygon(:,1)) < minX
            minX = min(envRegions(iRegion).polygon(:,1));
        end
        if min(envRegions(iRegion).polygon(:,2)) < minY
            minY = min(envRegions(iRegion).polygon(:,2));
        end
    end
    
    padding = params.fig1.envAxisPadding;
    axis([minX-padding, maxX+padding, minY-padding, maxY+padding]);
    
    %%% drawing the partitions (the side boundaries)
    hPartitions = zeros(length(partitions), 2);
    for iPartition = 1:length(partitions)
        partition = cell2mat(partitions(iPartition));
        hPartitions(iPartition, 1) = plot(partition(2:3,1), partition(2:3,2), 'black');
        hPartitions(iPartition, 2) = plot(partition(4:5,1), partition(4:5,2), 'black');
    end
elseif strcmp(action, 'update')
    for iAgent = 1:length(agents)
        if agents(iAgent).isAlive            
            set(hPartitions(iAgent, 1), 'XData', agents(iAgent).partition(2:3,1), 'YData', agents(iAgent).partition(2:3,2));
            set(hPartitions(iAgent, 2), 'XData', agents(iAgent).partition(4:5,1), 'YData', agents(iAgent).partition(4:5,2));
        else
            set(hPartitions(iAgent, 1), 'Visible', 'off');
            set(hPartitions(iAgent, 2), 'Visible', 'off');
        end
    end
end

end

