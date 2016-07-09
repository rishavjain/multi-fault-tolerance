function [Agents] = initialize_agents(params, regions, partitions, vPartitions, mapping)

NumAgents = params.agents.num;

Agents = struct();
Agents(1:NumAgents) = struct();

%%% initialize the agent properties
for i=1:NumAgents
    Agents(i).id = i;
    Agents(i).isAlive = 1;
    
    Agents(i).vPartition = cell2mat(vPartitions(i));
    Agents(i).vLimit = [Agents(i).vPartition(1,1) Agents(i).vPartition(2,1)]; % [x_start, x_end]
    Agents(i).vPosition = mean(Agents(i).vPartition(1:end-1,:));
    Agents(i).vTheta = 0;
    
    Agents(i).partition = cell2mat(partitions(i));
    Agents(i).position = map_virtual_pt(Agents(i).vPosition, regions, mapping);
    Agents(i).midPosition = Agents(i).position;
        
    Agents(i).commRange = params.agents.commrange;
    Agents(i).speed = params.agents.speed;    
    Agents(i).moveToMeeting = 0;
    
    Agents(i).agents = 1:NumAgents;
    Agents(i).neighbors = get_neighbors(Agents(i).agents, i);
    
    Agents(i).meetings = [];
    Agents(i).mode = 'normal';   % 1 -> normal, 2 -> recovery
    Agents(i).m1_remTime = 0;
    
    Agents(i).note = '';
    
    Agents(i).m2_num = 0;
    Agents(i).m2_remTime = 0;
    Agents(i).m2_neighbor = 0;
end

%%% initialize the meeting time and points for the agents
for i=1:NumAgents
    if isempty(Agents(i).meetings)
        meetingTime = 0;
        agentsToMeet = Agents(i).neighbors;
    else
        meetingTime = Agents(i).meetings(end,end);
        agentsToMeet = setdiff(Agents(i).neighbors, Agents(i).meetings(:,1));
    end
    
    for j=agentsToMeet
        meetingX = intersect(Agents(i).vLimit, Agents(j).vLimit);
        meetingTime = meetingTime + (3 * (Agents(i).vLimit(2) - Agents(i).vLimit(1)) / Agents(i).speed);
        
        Agents(i).meetings = [Agents(i).meetings; j meetingX Agents(i).vPosition(2) meetingTime];
        Agents(j).meetings = [Agents(j).meetings; i meetingX Agents(i).vPosition(2) meetingTime];
    end
    
    Agents(i).m1_remTime = Agents(i).meetings(1,4);
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