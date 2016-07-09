function draw_agents( params, agents, regions, mapping, action )
%DRAW_ENV Summary of this function goes here
%   Detailed explanation goes here

persistent hPartitionNums hCR hRobots CR_X CR_Y;

NumAgents = length(agents);

if strcmp(action, 'new')
    [CR_X, CR_Y] = pol2cart(linspace(0,2*pi,100), ones(1,100)*params.agents.commrange);
    
    for i = 1:NumAgents
        hCR(i) = patch(CR_X + agents(i).position(1), CR_Y + agents(i).position(2),'yellow', 'FaceAlpha', 0.7, 'EdgeColor', 'None');
        hRobots(i) = plot(agents(i).position(1), agents(i).position(2), '*k', 'MarkerSize', 2);
        hPartitionNums(i) = text(agents(i).midPosition(1), agents(i).midPosition(2), num2str(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end
elseif strcmp(action, 'update')
    for i = 1:NumAgents
        if agents(i).isAlive
            set(hCR(i), 'XData', CR_X + agents(i).position(1), 'YData', CR_Y + agents(i).position(2));
            set(hRobots(i), 'XData', agents(i).position(1), 'YData', agents(i).position(2));
            set(hPartitionNums(i), 'Position', [agents(i).midPosition(1), agents(i).midPosition(2)]);
        else
            set(hCR(i), 'Visible', 'off');
            set(hRobots(i), 'Visible', 'off');
            set(hPartitionNums(i), 'Visible', 'off');
        end
    end
    
end
end
