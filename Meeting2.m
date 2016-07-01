function [Agents, CommHistory] = Meeting2(A1, A2, Agents, CommHistory)

global TIME

for i=1:length(CommHistory)
    if isempty(setdiff(cell2mat(CommHistory(i)), [A1 A2]))
        return
    end
end

CommHistory(end+1) = {[A1, A2]};

if Agents(A1).Mode == 1 || Agents(A2).Mode == 1
    %     Agents(A1).Mode = 1;
    
    if ~isempty(find(Agents(A1).M2.neighbor == A2, 1))
        index = find(Agents(A1).M2.neighbor == A2, 1);
        Agents(A1).M2.num = Agents(A1).M2.num-1;
        
        if Agents(A1).M2.num == 0
            Agents(A1).Mode = 1;
        end
        
        Agents(A1).M2.neighbor = Agents(A1).M2.neighbor(Agents(A1).M2.neighbor~=A2);
        Agents(A1).M2.rem_time = Agents(A1).M2.rem_time(Agents(A1).M2.rem_time~=Agents(A1).M2.rem_time(index));
    end
    
    
    %     Agents(A2).Mode = 1;
    if ~isempty(find(Agents(A2).M2.neighbor == A1, 1))
        index = find(Agents(A2).M2.neighbor == A1, 1);
        Agents(A2).M2.num = Agents(A2).M2.num-1;
        
        if Agents(A2).M2.num == 0
            Agents(A2).Mode = 1;
        end
        
        Agents(A2).M2.neighbor = Agents(A2).M2.neighbor(Agents(A2).M2.neighbor~=A1);
        Agents(A2).M2.rem_time = Agents(A2).M2.rem_time(Agents(A2).M2.rem_time~=Agents(A2).M2.rem_time(index));
    end
    return;
end

%%% --------------------------------------------------------
%%% information exchange
Agents(A1).AGENTS = intersect(Agents(A1).AGENTS, Agents(A2).AGENTS);
Agents(A2).AGENTS = Agents(A1).AGENTS;
%%% --------------------------------------------------------

if ~isempty(find(Agents(A1).M2.neighbor == A2, 1))
    index = find(Agents(A1).M2.neighbor == A2, 1);
    Agents(A1).M2.num = Agents(A1).M2.num-1;
    
    if Agents(A1).M2.num == 0
        Agents(A1).Mode = 1;
    end
    
    Agents(A1).M2.neighbor = Agents(A1).M2.neighbor(Agents(A1).M2.neighbor~=A2);
    Agents(A1).M2.rem_time = Agents(A1).M2.rem_time(Agents(A1).M2.rem_time~=Agents(A1).M2.rem_time(index));
end

if ~isempty(find(Agents(A2).M2.neighbor == A1, 1))
    index = find(Agents(A2).M2.neighbor == A1, 1);
    Agents(A2).M2.num = Agents(A2).M2.num-1;
    
    if Agents(A2).M2.num == 0
        Agents(A2).Mode = 1;
    end
    
    Agents(A2).M2.neighbor = Agents(A2).M2.neighbor(Agents(A2).M2.neighbor~=A1);
    Agents(A2).M2.rem_time = Agents(A2).M2.rem_time(Agents(A2).M2.rem_time~=Agents(A2).M2.rem_time(index));
end

if isempty(find(Agents(A1).M2.neighbor == A2, 1)) && isempty(find(Agents(A2).M2.neighbor == A1, 1))
    fprintf('\n%d meets %d\n', A1, A2);
    Agents(A1).Mode = 1;
    Agents(A2).Mode = 1;
end

if A1 < A2
    i = A1; j = A2;
else
    i = A2; j = A1;
end

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

if isempty(Agents(A1).meeting) && isempty(Agents(A2).meeting)
    i = A1; j = A2;
    time = TIME;
elseif ~isempty(Agents(A1).meeting) && ~isempty(Agents(A2).meeting)
    if Agents(A1).meeting(end,3) > Agents(A2).meeting(end,3)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    if Agents(i).meeting(1,1) == j
        return;
    end
    
    time = Agents(i).meeting(end,3);
else
    if isempty(Agents(A2).meeting)
        i = A1; j = A2;
    else
        i = A2; j = A1;
    end
    time = Agents(i).meeting(end,3);
end

x = x_new;
time = time + (3 * (Agents(i).x_limit(2) - Agents(i).x_limit(1)) / Agents(i).Speed);
Agents(i).meeting = [Agents(i).meeting; j x time];
Agents(j).meeting = [Agents(j).meeting; i x time];


% Agents(i).meeting = Agents(i).meeting(2:end,:);
Agents(i).M.rem_time = Agents(i).meeting(1,3) - TIME;
Agents(i).flag.MOVE_TO_DEST = 0;
% set(Agents(i).H.ext_text, 'String', ...
%     sprintf('%s\nM2-\n%s\n%s', sprintf('%d %.2f\n', [Agents(i).meeting(:,1) Agents(i).meeting(:,3)]'), ...
%     sprintf('%d ', Agents(i).M2.neighbor), sprintf('%.2f ', Agents(i).M2.rem_time)));
% set(Agents(i).H.ext_text, 'Visible', 'on');

% Agents(j).meeting = Agents(j).meeting(2:end,:);
Agents(j).M.rem_time = Agents(j).meeting(1,3) - TIME;
Agents(j).flag.MOVE_TO_DEST = 0;
% set(Agents(j).H.ext_text, 'String', ...
%     sprintf('%s\nM2-\n%s\n%s', sprintf('%d %.2f\n', [Agents(j).meeting(:,1) Agents(j).meeting(:,3)]'), ...
%     sprintf('%d ', Agents(j).M2.neighbor), sprintf('%.2f ', Agents(j).M2.rem_time)));
% set(Agents(j).H.ext_text, 'Visible', 'on');