function [Agents, CommHistory] = Meeting(A1, A2, Agents, CommHistory)

global TIME LOC

for i=1:length(CommHistory)
    if isempty(setdiff(cell2mat(CommHistory(i)), [A1 A2]))
        return
    end
end

CommHistory(end+1) = {[A1, A2]};

% if pdist([Agents(A1).position; Agents(A2).position]) > 2*(Agents(A1).CommRange + Agents(A2).CommRange)
if ~Agents(A1).IS_ALIVE || ~Agents(A2).IS_ALIVE
    
    if Agents(A1).IS_ALIVE
        x = A1; y = A2;
    else
        x = A2; y = A1;
    end
    
    % fault occur
    fprintf('Fault Detected (%d) : %d\n', x, y);
    
    %%% if the agent now dead is seeked, remove it
    if ~isempty(find(Agents(x).M2.neighbor == y, 1))
        index = find(Agents(x).M2.neighbor == y, 1);
        Agents(x).M2.num = Agents(x).M2.num-1;
        Agents(x).M2.neighbor = Agents(x).M2.neighbor(Agents(x).M2.neighbor~=y);
        Agents(x).M2.rem_time = Agents(x).M2.rem_time(Agents(x).M2.rem_time~=Agents(x).M2.rem_time(index));
    end
    
    Agents(x).meeting = Agents(x).meeting(2:end,:);
    
    Agents(x).AGENTS = Agents(x).AGENTS(Agents(x).AGENTS ~= y); % remove dead agent from the list
    
    %%% if only one agent is alive
    if length(Agents(x).AGENTS) == 1
        Agents(x).Mode = 0;
        
        Agents(x).x_limit(1) = min(Agents(x).x_limit(1), Agents(y).x_limit(1));
        Agents(x).x_limit(2) = max(Agents(x).x_limit(2), Agents(y).x_limit(2));
        Agents(x).polygon = GET_POLYGON(Agents(x).x_limit);
        
        return;
    end
    
    new_neighborS = GET_NEIGHBORS(Agents(x).AGENTS, x);
    Agents(x).neighbors = new_neighborS;
    
    if y>x
        new_neighbor = new_neighborS(end);
    else
        new_neighbor = new_neighborS(1);
    end
    
    Agents(x).x_limit(1) = min(Agents(x).x_limit(1), Agents(y).x_limit(1));
    Agents(x).x_limit(2) = max(Agents(x).x_limit(2), Agents(y).x_limit(2));
    Agents(x).polygon = GET_POLYGON(Agents(x).x_limit);
    
    if ~isempty(Agents(x).meeting)
        Agents(x).M.rem_time = Agents(x).meeting(1,3) - TIME;
        Agents(x).flag.MOVE_TO_DEST = 0;
%         set(Agents(x).H.ext_text, 'String', sprintf('%d %.2f\n', [Agents(x).meeting(:,1) Agents(x).meeting(:,3)]'));
    end
    Agents(x).Mode = 2;
    
    if isempty(find(Agents(x).M2.neighbor == new_neighbor,1))
        Agents(x).M2.num = Agents(x).M2.num + 1;
        Agents(x).M2.rem_time(Agents(x).M2.num) = (9 * (Agents(x).x_limit(2) - Agents(x).x_limit(1)) / Agents(x).Speed);
        Agents(x).M2.neighbor(Agents(x).M2.num) = new_neighbor;
    end
    
    Agents(x).position(2) = LOC(2);
    Agents(x).theta = (randi(2)-1)*pi;
    
    if isempty(Agents(x).meeting)
%         set(Agents(x).H.ext_text, 'String', '');
    end
    
    
    
    %     Agents(x).Mode = 2;
    %     set(Agents(x).H.polygon, 'XData', Agents(x).polygon(:,1), 'YData', Agents(x).polygon(:,2));
    
else
    %     Info = intersect(Agents(A1).Info,Agents(A2).Info);
    %
    %     for A=[A1,A2]
    %         if ~isempty(setdiff(Agents(A).Info,Info))
    %             % conflict in info
    %             Agents(A).Info = Info;
    %         end
    %     end
    
    if pdist([Agents(A1).position; Agents(A2).position]) > (Agents(A1).CommRange + Agents(A2).CommRange)
        fprintf('!! CHECK !!\n');
    end
    
    %%% --------------------------------------------------------
    %%% information exchange
    Agents(A1).AGENTS = intersect(Agents(A1).AGENTS, Agents(A2).AGENTS);
    Agents(A2).AGENTS = Agents(A1).AGENTS;
    %%% --------------------------------------------------------
    %%% adjusting partitions
    if A1 < A2
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    
    if (Agents(i).x_limit(2) - Agents(i).x_limit(1)) ~= (Agents(j).x_limit(2) - Agents(j).x_limit(1))
        x_new = (Agents(i).x_limit(1) + Agents(j).x_limit(2))/2;
        
        Agents(i).x_limit = [Agents(i).x_limit(1), x_new];
        Agents(i).polygon = GET_POLYGON(Agents(i).x_limit);
        
        Agents(j).x_limit = [x_new, Agents(j).x_limit(2)];
        Agents(j).polygon = GET_POLYGON(Agents(j).x_limit);
        
        global A;
        A(i).VirtualPartition.Start = Agents(i).x_limit(1);
        A(i).VirtualPartition.End = Agents(i).x_limit(2);
        
        A(j).VirtualPartition.Start = Agents(j).x_limit(1);
        A(j).VirtualPartition.End = Agents(j).x_limit(2);
        
    end
    
    %%% --------------------------------------------------------
    
    %%% --------------------------------------------------------
    %%% set next meeting time
    if Agents(A1).meeting(end,3) > Agents(A2).meeting(end,3)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    
    x = intersect(Agents(i).x_limit, Agents(j).x_limit);
    
    if isempty(x)
        x_new = [Agents(i).x_limit Agents(j).x_limit];
        x_new = mean([min(x_new) max(x_new)]);
        
        Agents(i).x_limit = [Agents(i).x_limit(1), x_new];
        Agents(i).polygon = GET_POLYGON(Agents(i).x_limit);
        
        Agents(j).x_limit = [x_new, Agents(j).x_limit(2)];
        Agents(j).polygon = GET_POLYGON(Agents(j).x_limit);
        
        x = x_new;
    end
    
    time = Agents(i).meeting(end,3) + (3 * (Agents(i).x_limit(2) - Agents(i).x_limit(1)) / Agents(i).Speed);
    Agents(i).meeting = [Agents(i).meeting; j x time];
    Agents(j).meeting = [Agents(j).meeting; i x time];
    
    Agents(i).meeting = Agents(i).meeting(2:end,:);
    Agents(i).M.rem_time = Agents(i).meeting(1,3) - TIME;
    Agents(i).flag.MOVE_TO_DEST = 0;
%     set(Agents(i).H.ext_text, 'String', sprintf('%d %.2f\n', [Agents(i).meeting(:,1) Agents(i).meeting(:,3)]'));
    
    Agents(j).meeting = Agents(j).meeting(2:end,:);
    Agents(j).M.rem_time = Agents(j).meeting(1,3) - TIME;
    Agents(j).flag.MOVE_TO_DEST = 0;
%     set(Agents(j).H.ext_text, 'String', sprintf('%d %.2f\n', [Agents(j).meeting(:,1) Agents(j).meeting(:,3)]'));
    %%% ------------------------------------------------------
end