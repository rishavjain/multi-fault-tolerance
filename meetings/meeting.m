function [agents, commHistory] = meeting(A1, A2, agents, commHistory, params, time)

%%% if meeting already done by other agent
for i=1:length(commHistory)
    if isempty(setdiff(cell2mat(commHistory(i)), [A1 A2]))
        return
    end
end
commHistory(end+1) = {[A1, A2]};


if agents(A1).isAlive && agents(A2).isAlive
    %%% when both the agents are alive
    
    logger(params, 1, sprintf('time=%.2f, agents %d and %d meet', time, A1, A2));
    
    if pdist([agents(A1).vPosition; agents(A2).vPosition]) > (agents(A1).commRange + agents(A2).commRange)
        logger(params, 3, sprintf('time=%.2f, agents %d and %d missed the meeting point', time, A1, A2));
    end
    
    %%% --------------------------------------------------------
    %%% information exchange
    agents(A1).agents = intersect(agents(A1).agents, agents(A2).agents);
    agents(A2).agents = agents(A1).agents;
    %%% --------------------------------------------------------
    %%% adjusting partitions
    if A1 < A2
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    
    if (agents(i).vLimit(2) - agents(i).vLimit(1)) ~= (agents(j).vLimit(2) - agents(j).vLimit(1))
        x_ = (agents(i).vLimit(1) + agents(j).vLimit(2))/2;
        
        agents(i).vLimit = [agents(i).vLimit(1), x_];
        agents(i).vPartition = [agents(i).vLimit(1) 0;
            agents(i).vLimit(2) 0 ;
            agents(i).vLimit(2) agents(i).vPartition(3,2);
            agents(i).vLimit(1) agents(i).vPartition(3,2);
            agents(i).vLimit(1) 0];
        
        agents(j).vLimit = [x_, agents(j).vLimit(2)];
        agents(j).vPartition = [agents(j).vLimit(1) 0;
            agents(j).vLimit(2) 0 ;
            agents(j).vLimit(2) agents(j).vPartition(3,2);
            agents(j).vLimit(1) agents(j).vPartition(3,2);
            agents(j).vLimit(1) 0];
    end
    
    %%% --------------------------------------------------------
    
    %%% --------------------------------------------------------
    %%% set next meeting time
    if agents(A1).meetings(end,4) > agents(A2).meetings(end,4)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    
    x = intersect(agents(i).vLimit, agents(j).vLimit);
    y = agents(i).vPartition(3,2)/2;
    
    t = agents(i).meetings(end,4) + (3 * (agents(i).vLimit(2) - agents(i).vLimit(1)) / agents(i).speed);
    agents(i).meetings = [agents(i).meetings; j x y t];
    agents(j).meetings = [agents(j).meetings; i x y t];
    
    agents(i).meetings = agents(i).meetings(2:end,:);
    agents(i).m1_remTime = agents(i).meetings(1,4) - time;
    agents(i).moveToMeeting = 0;
    
    agents(j).meetings = agents(j).meetings(2:end,:);
    agents(j).m1_remTime = agents(j).meetings(1,4) - time;
    agents(j).moveToMeeting = 0;
    %%% ------------------------------------------------------
else
    if agents(A1).isAlive
        x = A1; y = A2;
    else
        x = A2; y = A1;
    end
    
    % fault occur
    logger(params, 2, sprintf('time=%.2f, fault detected (%d) : %d\n', time, x, y));
    
    %%% if the agent now dead is seeked, remove it
    if ~isempty(find(agents(x).m2_neighbor == y, 1))
        index = find(agents(x).m2_neighbor == y, 1);
        
        agents(x).m2_num = agents(x).m2_num - 1;
        agents(x).m2_neighbor = agents(x).m2_neighbor( agents(x).m2_neighbor ~= y );
        agents(x).m2_remTime = agents(x).m2_remTime( agents(x).m2_remTime ~= agents(x).m2_remTime(index) );
    end
    
    agents(x).meetings = agents(x).meetings(2:end,:);
    
    agents(x).agents = agents(x).agents( agents(x).agents ~= y ); % remove dead agent from the list
    
    %%% if only one agent is alive
    if length(agents(x).agents) == 1
        agents(x).mode = 'single';
        
        agents(x).vLimit(1) = min(agents(x).vLimit(1), agents(y).vLimit(1));
        agents(x).vLimit(2) = max(agents(x).vLimit(2), agents(y).vLimit(2));
        agents(x).vPartition = [agents(x).vLimit(1) 0;
            agents(x).vLimit(2) 0 ;
            agents(x).vLimit(2) agents(x).vPartition(3,2);
            agents(x).vLimit(1) agents(x).vPartition(3,2);
            agents(x).vLimit(1) 0];
        
        return;
    end
    
    newNeighbors = get_neighbors(agents(x).agents, x);
    agents(x).neighbors = newNeighbors;
    
    if y>x
        newNeighbor = newNeighbors(end);
    else
        newNeighbor = newNeighbors(1);
    end
    
    agents(x).vLimit(1) = min(agents(x).vLimit(1), agents(y).vLimit(1));
    agents(x).vLimit(2) = max(agents(x).vLimit(2), agents(y).vLimit(2));
    agents(x).polygon = [agents(x).vLimit(1) 0;
            agents(x).vLimit(2) 0 ;
            agents(x).vLimit(2) agents(x).vPartition(3,2);
            agents(x).vLimit(1) agents(x).vPartition(3,2);
            agents(x).vLimit(1) 0];
    
    if ~isempty(agents(x).meetings)
        agents(x).m1_remTime = agents(x).meetings(1,4) - time;
        agents(x).moveToMeeting = 0;
    end
    
    agents(x).mode = 'recovery';
    
    if isempty(find(agents(x).m2_neighbor == newNeighbor,1))
        agents(x).m2_num = agents(x).m2_num + 1;
        agents(x).m2_remTime(agents(x).m2_num) = (9 * (agents(x).vLimit(2) - agents(x).vLimit(1)) / agents(x).speed);
        agents(x).m2_neighbor(agents(x).m2_num) = newNeighbor;
    end
    
    agents(x).vPosition(2) = agents(x).vPartition(3,2)/2;
    agents(x).vTheta = (randi(2)-1)*pi;
end

end

function n = get_neighbors(list, x)

pos = find(list==x);

if pos == 1
    n = list(pos+1);
elseif pos == length(list)
    n = list(pos-1);
else
    n = [list(pos-1), list(pos+1)];
end

end