function [ agents ] = move_agents(agents, dT, regions, mapping, params, time)

nAgents = length(agents);

CommHistory = {};

for i=1:nAgents
    
    if ~agents(i).isAlive
        continue;
    end
    
    stepSize = dT * agents(i).speed;
    
    if strcmp(agents(i).mode, 'normal')
        
        if isempty(agents(i).meetings)
            logger(params, 3, sprintf('time: %d, agent %d: no meetings set in normal mode', time, i));
            continue;
        end
        
        if agents(i).m1_remTime <= 0
            [agents, CommHistory] = meeting(i, agents(i).meetings(1,1), agents, CommHistory, params, time);
        end
        
        if isempty(agents(i).meetings)
            logger(params, 3, sprintf('time: %d, agent %d: no meetings set in normal mode', time, i));
            continue;
        end
        
        remDist = pdist([agents(i).meetings(1,2), agents(i).meetings(1,3); agents(i).vPosition], 'euclidean');
        
        if ((agents(i).m1_remTime)*agents(i).speed > (stepSize+remDist)) && ~agents(i).moveToMeeting
            %%% if agent has time to explore
            [agents(i).vPosition, agents(i).vTheta, agents(i).position] = getNewPosition(agents(i), 'None', stepSize, regions, mapping);
        else
            [agents(i).vPosition, agents(i).vTheta, agents(i).position] = getNewPosition(agents(i), agents(i).meetings(1,2:3), stepSize, regions, mapping);
            agents(i).moveToMeeting = 1;
        end
        
        agents(i).m1_remTime = agents(i).m1_remTime - dT;
        agents(i).note = '';
    end
    
    if strcmp(agents(i).mode, 'recovery')
        
        recoveryFlag = 0;
        
        if ~isempty(agents(i).meetings)
            if agents(i).meetings(1,4)-time <= 0
                
                [agents, CommHistory] = meeting(i, agents(i).meetings(1,1), agents, CommHistory, params, time);
                
            elseif agents(i).meetings(1,4)-time < 1.2*abs(agents(i).meetings(1,2) - agents(i).vPosition(1))/agents(i).speed
                
                [agents(i).vPosition, agents(i).vTheta, agents(i).position] = getNewPosition(agents(i), agents(i).meetings(2:3), stepSize, regions, mapping);
                recoveryFlag = 1;
            end
        end
        
        agents(i).note = sprintf('recovery search: agents=(%s), timeouts=(%s)', sprintf('%d,',agents(i).m2_neighbor), sprintf('%.2f,',agents(i).m2_remTime));
        
        for n=1:agents(i).m2_num
            if pdist([agents(agents(i).m2_neighbor(n)).vPosition; agents(i).vPosition]) <= 2*agents(i).commRange
                [agents, CommHistory] = meeting_recovery(i, agents(i).m2_neighbor(n), agents, CommHistory, params, time);
                
                if n>=agents(i).m2_num
                    break;
                end
            end
            
            if agents(i).m2_remTime(n) <= 0
                y = agents(i).m2_neighbor(n);
                x = i;
                
                agents(x).agents = agents(x).agents(agents(x).agents ~= y);
                
                %%% if only one agent is alive
                if length(agents(x).agents) == 1
                    agents(x).mode = 0;
                    
                    agents(x).vLimit(1) = min(agents(x).vLimit(1), agents(y).vLimit(1));
                    agents(x).vLimit(2) = max(agents(x).vLimit(2), agents(y).vLimit(2));
                    agents(x).vPartition = [agents(x).vLimit(1) 0;
                        agents(x).vLimit(2) 0 ;
                        agents(x).vLimit(2) agents(x).vPartition(3,2);
                        agents(x).vLimit(1) agents(x).vPartition(3,2);
                        agents(x).vLimit(1) 0];
                    
                    break;
                end
                
                newNeighbors = get_neighbors(agents(x).agents, x);
                agents(x).neighbors = newNeighbors;
                
                if y>x
                    new_neighbor = newNeighbors(end);
                else
                    new_neighbor = newNeighbors(1);
                end
                
                agents(x).vLimit(1) = min(agents(x).vLimit(1), agents(y).vLimit(1));
                agents(x).vLimit(2) = max(agents(x).vLimit(2), agents(y).vLimit(2));
                agents(x).vPartition = [agents(x).vLimit(1) 0;
                    agents(x).vLimit(2) 0 ;
                    agents(x).vLimit(2) agents(x).vPartition(3,2);
                    agents(x).vLimit(1) agents(x).vPartition(3,2);
                    agents(x).vLimit(1) 0];
                
                agents(x).m2_remTime(n) = (9 * (agents(x).vLimit(2) - agents(x).vLimit(1)) / agents(x).speed);
                agents(x).m2_neighbor(n) = new_neighbor;
            end
            
            agents(i).m2_remTime(n) = agents(i).m2_remTime(n)-dT;
        end
        
        if recoveryFlag == 0            
            [agents(i).vPosition, agents(i).vTheta, agents(i).position] = getNewPosition(agents(i), 'None', stepSize, regions, mapping);
        end
    end
    
    if strcmp(agents(i).mode, 'single')
        agents(i).note = 'single agent';
        [agents(i).vPosition, agents(i).vTheta, agents(i).position] = getNewPosition(agents(i), 'None', stepSize, regions, mapping);
    end
    
    agents(i).midPosition = map_virtual_pt(mean(agents(i).vPartition(2:end,:)), regions, mapping);
        
    for vertexId = 1:size(agents(i).vPartition, 1)
        agents(i).partition(vertexId, :) = map_virtual_pt( agents(i).vPartition(vertexId,:), regions, mapping );        
    end
end

end

function [vpos_, vtheta_, pos_] = getNewPosition(agent, headingPt, stepSize, regions, mapping)

if strcmp(agent.mode, 'recovery')
    vtheta_ = agent.vTheta;
    
    vpos_ = [agent.vPosition(1) + stepSize*cos(agent.vTheta) agent.vPosition(2)];
    
    if(inpolygon(vpos_(1), vpos_(2), agent.vPartition(:,1), agent.vPartition(:,2))==0)
        m = mean(agent.vPartition(1:end-1,:));
        
        vtheta_ = (m(1)<agent.vPosition(1))*pi + (m(1)>agent.vPosition(1))*0;
        vpos_ = [agent.vPosition(1)+stepSize*cos(vtheta_) agent.vPosition(2)];
    end
    
    pos_ = map_virtual_pt( vpos_, regions, mapping );
else
    if isequal(headingPt, 'None')
        vtheta_ = agent.vTheta + 0.4*(pi*rand - pi/2);
        
        vpos_ = [agent.vPosition(1) + stepSize*cos(vtheta_), agent.vPosition(2) + stepSize*sin(vtheta_)];
        %         vpos_ = revmap_virtual_pt( pos_, regions, mapping );
        
        if(inpolygon(vpos_(1), vpos_(2), agent.vPartition(:,1), agent.vPartition(:,2))==0)
            [vpos_, vtheta_, pos_] = getNewPosition(agent, mean(agent.vPartition(1:end-1,:)), stepSize, regions, mapping);
        else
            pos_ = map_virtual_pt( vpos_, regions, mapping );
        end
    else
        vtheta_ = atan2(headingPt(2) - agent.vPosition(2), headingPt(1) - agent.vPosition(1));
        
        vpos_ = [agent.vPosition(1) + stepSize*cos(vtheta_), agent.vPosition(2) + stepSize*sin(vtheta_)];
        
        step = stepSize;
        if inpolygon(agent.vPosition(1), agent.vPosition(2), agent.vPartition(:,1), agent.vPartition(:,2))==1
            while(inpolygon(vpos_(1), vpos_(2), agent.vPartition(:,1), agent.vPartition(:,2))==0)
                step = step/2;
                vpos_ = [agent.vPosition(1) + step*cos(vtheta_), agent.vPosition(2) + step*sin(vtheta_)];
            end
        end
        
        pos_ = map_virtual_pt( vpos_, regions, mapping );
    end    
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