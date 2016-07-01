%%% main file for simulation

global NumberOfAgents;
NumberOfAgents = 10;

global A;
A = struct();
A(1:NumberOfAgents) = struct();

for agentId = 1:NumberOfAgents
    A(agentId).Speed = randi([200 200]);
end

clear agentId;

Virtual;

% error 'stop!';
% MapEnvironment;

PopulateRegions;

% error 'Stop';

global Speed;
Speed = mean([A.Speed]);
global dT;
dT = 0.025; % time step size

NUM_AGENTS = NumberOfAgents;
global partitionH Agents;
Agents = A;
partitionH = 0.4 * TotalVirtualLength;
global LOC
LOC = [0, partitionH/2];
Comm_Range = 1.5;
Speed = 30;
global CR_X CR_Y
[CR_X, CR_Y] = pol2cart(linspace(0,2*pi,100), ones(1,100)*Comm_Range);

for i=1:length(Agents)
    Agents(i).ID = i;
    Agents(i).IS_ALIVE = 1;
    
    Agents(i).x_limit = [A(i).VirtualPartition.Start, A(i).VirtualPartition.End]; %[(i-1)*partitionW i*partitionW];
    Agents(i).polygon = A(i).VirtualPartition.Partition; %[Agents(i).x_limit(1) 0 ;
    %         Agents(i).x_limit(2) 0 ;
    %         Agents(i).x_limit(2) partitionH ;
    %         Agents(i).x_limit(1) partitionH ;
    %         Agents(i).x_limit(1) 0];
    
    Agents(i).H.polygon = A(i).VirtualPartition.handleFill; %fill(Agents(i).polygon(:,1), Agents(i).polygon(:,2), 'w');
    
%     Agents(i).H.poly_text = A(i).VirtualPartition.handleText; %text(mean(Agents(i).x_limit), partitionH/2, num2str(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
%     Agents(i).H.ext_text = text(Agents(i).x_limit(1)+1, partitionH, '', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    
    Agents(i).position = [mean(Agents(i).x_limit), partitionH/2];
    Agents(i).theta = 0;
    
    global Regions Mapping
    regionIndex = find(Mapping(:,1) <= Agents(i).position(1), 1, 'last');
    [positionX, positionY] = Regions(regionIndex).mapVirtualPoint(Agents(i).position(1), Agents(i).position(2), Mapping(regionIndex,:));
    
    Agents(i).H.CR = patch(CR_X + positionX, CR_Y + positionY,'y', 'FaceAlpha', 0.7, 'EdgeColor', 'none');
    Agents(i).H.robot = plot(positionX, positionY, '*k', 'MarkerSize', 2);
    
    Agents(i).CommRange = Comm_Range;
    Agents(i).Speed = Speed;
    
    Agents(i).Mode = 1;
    
    Agents(i).meeting = [];
    Agents(i).flag.MOVE_TO_DEST = 0;
    
    Agents(i).M.rem_time = 0;
    
    Agents(i).AGENTS = 1:NUM_AGENTS;
    Agents(i).neighbors = GET_NEIGHBORS(Agents(i).AGENTS, i);
    
    Agents(i).M2.num = 0;
    Agents(i).M2.rem_time = 0;
    Agents(i).M2.neighbor = 0;
end

for i=1:length(Agents)
    if isempty(Agents(i).meeting)
        time = 0;
        to_check = Agents(i).neighbors;
    else
        time = Agents(i).meeting(end,end);
        to_check = setdiff(Agents(i).neighbors, Agents(i).meeting(:,1));
    end
    
    for j=to_check
        x = intersect(Agents(i).x_limit, Agents(j).x_limit);
        time = time + (1.5 * (Agents(i).x_limit(2) - Agents(i).x_limit(1)) / Agents(i).Speed);
        Agents(i).meeting = [Agents(i).meeting; j x time];
        Agents(j).meeting = [Agents(j).meeting; i x time];
    end
    
    Agents(i).M.rem_time = Agents(i).meeting(1,3);
%     set(Agents(i).H.ext_text, 'String', sprintf('%d %.2f\n', [Agents(i).meeting(:,1) Agents(i).meeting(:,3)]'));
    
    clear time to_check x j
end


agentsTableH = uitable('Position', [10 10 300 700]);
extrasTableH = uitable('Position', [10 720 300 150], 'RowName', {'Time','dT'}, 'ColumnName', {''}, ...
    'FontUnits', 'normalized', 'FontSize', 0.25, 'ColumnWidth', {200});

UI_UpdatePartitions();

global KILL_AGENT PAUSE_SIMULATION DEBUG_TIME
KILL_AGENT = [];
PAUSE_SIMULATION = 1;
DEBUG_TIME = intmax;

uicontrol('Style', 'pushbutton', 'String', 'Kill Agent', 'Position', [400 100 100 40], 'Callback', @UI_KillAgent);
uicontrol('Style', 'pushbutton', 'String', 'Resume', 'Position', [600 100 100 40], 'Callback', @UI_PauseSimulation);
uicontrol('Style', 'pushbutton', 'String', 'Debug at Time', 'Position', [800 100 100 40], 'Callback', @UI_DebugAgent);
uicontrol('Style', 'text', 'Position', [1000 110 400 30], 'String', 'Speed');
uicontrol('Style', 'slider', 'Min', 1, 'Max', 200,'Value', Agents(i).Speed, 'Position', [1000 100 400 10], 'Callback', @UI_SpeedSlider);

%%% starting simulation
global TIME;
TIME = 0;

global Step_Size

axis equal;

h = struct();
% h.time = text(-15, LOC(2), '', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

set(extrasTableH, 'Data', [TIME;dT]);

t1 = clock;
while TIME<6000
    
    if ~ishandle(2)
        return;
    end
    
    if PAUSE_SIMULATION
        pause(0.1);
        continue;
    end
    
    if DEBUG_TIME<TIME
        DEBUG_TIME = intmax;
        continue;
    end
    
    t2 = clock;
    if etime(t2, t1)>dT
        t1 = t2;
        
        CommHistory = {};
        
        for i=1:length(Agents)
            if Agents(i).IS_ALIVE == 1
                Step_Size = dT * Agents(i).Speed;
                if Agents(i).Mode == 1
                    
                    if isempty(Agents(i).meeting)
                        continue;
                    end
                    
                    if Agents(i).M.rem_time <= 0
                        [Agents, CommHistory] = Meeting(i, Agents(i).meeting(1,1), Agents, CommHistory);
                    end
                    
                    if isempty(Agents(i).meeting)
                        continue;
                    end
                    
                    rem_distance = pdist([Agents(i).meeting(1,2), LOC(2); Agents(i).position], 'euclidean');
                    
                    if ((Agents(i).M.rem_time)*Agents(i).Speed > (Step_Size+rem_distance)) && ~Agents(i).flag.MOVE_TO_DEST                        
                        [Agents(i).position, Agents(i).theta] = ...
                            GET_NEXT_POSITION(1, Agents(i).position, Agents(i).theta, Agents(i).polygon, []);
                    else
                        [Agents(i).position, Agents(i).theta] = ...
                            GET_NEXT_POSITION(1, Agents(i).position, Agents(i).theta, Agents(i).polygon, [Agents(i).meeting(1,2), LOC(2)]);
                        Agents(i).flag.MOVE_TO_DEST = 1;
                    end
                    
                    if ~ishandle(2)
                        return;
                    end
                    
                    Agents(i).M.rem_time = Agents(i).M.rem_time - dT;
                end
                
                if Agents(i).Mode == 2
                    
                    FLAG_M2 = 0;
                    if ~isempty(Agents(i).meeting)
                        if Agents(i).meeting(1,3)-TIME <= 0
                            [Agents, CommHistory] = Meeting(i, Agents(i).meeting(1,1), Agents, CommHistory);
                        elseif Agents(i).meeting(3)-TIME < 1.2*abs(Agents(i).meeting(2) - Agents(i).position(1))/Agents(i).Speed
                            [new_pos, new_theta] = GET_NEXT_POSITION(1, Agents(i).position, Agents(i).theta, ...
                                Agents(i).polygon, [Agents(i).meeting(2), LOC(2)]);
                            FLAG_M2 = 1;
                        end
                    end
                    
                    %                     set(Agents(i).H.ext_text, 'String', ...
                    %                         sprintf('%s\nM2-\n%s\n%s', sprintf('%d %.2f\n', [Agents(i).meeting(:,1) Agents(i).meeting(:,3)]'), ...
                    %                         sprintf('%d ', Agents(i).M2.neighbor), sprintf('%.2f ', Agents(i).M2.rem_time)));
                    
                    FLAG_M2_2 = 0;
                    for iagentId = setdiff(find([Agents.IS_ALIVE]==1), i)
                        if pdist([Agents(iagentId).position; Agents(i).position]) <= 2*Agents(i).CommRange ...
                                && Agents(iagentId).Mode == 2
                            [Agents, CommHistory] = Meeting2(i, iagentId, Agents, CommHistory);
                            FLAG_M2_2 = 1;
                            break;
                        end
                    end
                    
                    if FLAG_M2_2 == 0
                        for n=1:Agents(i).M2.num
                            if pdist([Agents(Agents(i).M2.neighbor(n)).position; Agents(i).position]) <= 2*Agents(i).CommRange
                                [Agents, CommHistory] = Meeting2(i, Agents(i).M2.neighbor(n), Agents, CommHistory);
                                
                                if n>=Agents(i).M2.num
                                    break;
                                end
                            end
                            
                            if Agents(i).M2.rem_time(n) <= 0
                                y = Agents(i).M2.neighbor(n);
                                x = i;
                                
                                Agents(x).AGENTS = Agents(x).AGENTS(Agents(x).AGENTS ~= y);
                                
                                %%% if only one agent is alive
                                if length(Agents(x).AGENTS) == 1
                                    Agents(x).Mode = 0;
                                    
                                    Agents(x).x_limit(1) = min(Agents(x).x_limit(1), Agents(y).x_limit(1));
                                    Agents(x).x_limit(2) = max(Agents(x).x_limit(2), Agents(y).x_limit(2));
                                    Agents(x).polygon = GET_POLYGON(Agents(x).x_limit);
                                    
                                    break;
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
                                
                                Agents(x).M2.rem_time(n) = (9 * (Agents(x).x_limit(2) - Agents(x).x_limit(1)) / Agents(x).Speed);
                                Agents(x).M2.neighbor(n) = new_neighbor;
                                
                                clear x y
                            end
                            
                            Agents(i).M2.rem_time(n) = Agents(i).M2.rem_time(n)-dT;
                        end
                    end
                    if FLAG_M2 == 0
                        [new_pos, new_theta] = ...
                            GET_NEXT_POSITION(2, Agents(i).position, Agents(i).theta, Agents(i).polygon);
                    end
                    
                    Agents(i).position = new_pos;
                    Agents(i).theta = new_theta;
                    clear new_pos new_theta
                    
                    if ~ishandle(2)
                        return;
                    end
                end
                
                if Agents(i).Mode == 0
                    [Agents(i).position, Agents(i).theta] = ...
                        GET_NEXT_POSITION(1, Agents(i).position, Agents(i).theta, Agents(i).polygon, []);
                end
            end
        end
        
        if ~ishandle(2)
            return;
        end
        
        Agents = UI_UpdateAgents(Agents);
        
        if ~isempty(KILL_AGENT)
            
            for k=KILL_AGENT
                Agents(k).IS_ALIVE = 0;
                A(k).isLive = 0;
                Agents(k).position = [1000,0];
                
                fields = fieldnames(Agents(k).H);
                
                for i=1:length(fields)
                    set(Agents(k).H.(fields{i}), 'Visible', 'off');
                end
                
                A(i).VirtualPartition.Start = Agents(i).x_limit(1);
                A(i).VirtualPartition.End = Agents(i).x_limit(2);
                
            end
            KILL_AGENT = [];
            
            clear fields k
        end
        
        TIME = TIME + dT;
        %         set(h.time, 'String', sprintf('TIME : %.2f', TIME));
        set(extrasTableH, 'Data', [TIME;dT]);
        drawnow
    end
end