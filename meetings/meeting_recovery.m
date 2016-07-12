function [agents, commHistory] = meeting_recovery(A1, A2, agents, commHistory, params, time)

for i=1:length(commHistory)
    if isempty(setdiff(cell2mat(commHistory(i)), [A1 A2]))
        return
    end
end
commHistory(end+1) = {[A1, A2]};

%%% when only one agent is in recovery mode
if strcmp(agents(A1).mode, 'normal') || strcmp(agents(A2).mode, 'normal')
    if ~isempty(find(agents(A1).m2_neighbor == A2, 1))
        index = find(agents(A1).m2_neighbor == A2, 1);
        agents(A1).m2_num = agents(A1).m2_num-1;
        
        if agents(A1).m2_num == 0
            agents(A1).mode = 'normal';
        end
        
        agents(A1).m2_neighbor = agents(A1).m2_neighbor(agents(A1).m2_neighbor~=A2);
        agents(A1).m2_remTime = agents(A1).m2_remTime( agents(A1).m2_remTime ~= agents(A1).m2_remTime(index) );
    end
    
    if ~isempty(find(agents(A2).m2_neighbor == A1, 1))
        index = find(agents(A2).m2_neighbor == A1, 1);
        agents(A2).m2_num = agents(A2).m2_num-1;
        
        if agents(A2).m2_num == 0
            agents(A2).mode = 'normal';
        end
        
        agents(A2).m2_neighbor = agents(A2).m2_neighbor(agents(A2).m2_neighbor~=A1);
        agents(A2).m2_remTime = agents(A2).m2_remTime(agents(A2).m2_remTime~=agents(A2).m2_remTime(index));
    end
    return;
end

%%% --------------------------------------------------------
%%% information exchange
agents(A1).agents = intersect(agents(A1).agents, agents(A2).agents);
agents(A2).agents = agents(A1).agents;
%%% --------------------------------------------------------

if ~isempty(find(agents(A1).m2_neighbor == A2, 1))
    index = find(agents(A1).m2_neighbor == A2, 1);
    agents(A1).m2_num = agents(A1).m2_num-1;
    
    if agents(A1).m2_num == 0
        agents(A1).mode = 'normal';
        agents(A1).moveToMeeting = 0;
    end
    
    agents(A1).m2_neighbor = [agents(A1).m2_neighbor(1:index-1), agents(A1).m2_neighbor(index+1:end )];
    agents(A1).m2_remTime = [agents(A1).m2_remTime(1:index-1), agents(A1).m2_remTime(index+1:end)];
end

if ~isempty(find(agents(A2).m2_neighbor == A1, 1))
    index = find(agents(A2).m2_neighbor == A1, 1);
    agents(A2).m2_num = agents(A2).m2_num-1;
    
    if agents(A2).m2_num == 0
        agents(A2).mode = 'normal';
        agents(A2).moveToMeeting = 0;
    end
    
    agents(A2).m2_neighbor = [agents(A2).m2_neighbor(1:index-1), agents(A2).m2_neighbor(index+1:end)];
    agents(A2).m2_remTime = [agents(A2).m2_remTime(1:index-1), agents(A2).m2_remTime(index+1:end)];
end

if A1 < A2
    i = A1; j = A2;
else
    i = A2; j = A1;
end

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

if isempty(agents(A1).meetings) && isempty(agents(A2).meetings)
    i = A1; j = A2;
    refMeetTime = time;
    
elseif ~isempty(agents(A1).meetings) && ~isempty(agents(A2).meetings)
    if agents(A1).meetings(end,4) > agents(A2).meetings(end,4)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    
    if ~isempty(find(agents(i).meetings(:,1) == j, 1))
        return;
    end
    
    refMeetTime = agents(i).meetings(end,4);
else
    if isempty(agents(A2).meetings)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    refMeetTime = agents(i).meetings(end,4);
end

x = x_;
y = agents(i).vPartition(3,2)/2;

meetTime = refMeetTime + (3 * (agents(i).vLimit(2) - agents(i).vLimit(1)) / agents(i).speed);
agents(i).meetings = [agents(i).meetings; j x y meetTime];
agents(j).meetings = [agents(j).meetings; i x y meetTime];


agents(i).m1_remTime = agents(i).meetings(1,4) - time;
agents(j).m1_remTime = agents(j).meetings(1,4) - time;
