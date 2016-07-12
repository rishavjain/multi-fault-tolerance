function [ agents ] = move_agents(agents, dT, regions, mapping, params, time)

nAgents = length(agents);

commHistory = {};

for iAgent=1:nAgents
    
    if ~agents(iAgent).isAlive
        continue;
    end
    
    stepSize = dT * agents(iAgent).speed;
    
    if strcmp(agents(iAgent).mode, 'normal')
        
        if isempty(agents(iAgent).meetings)
            logger(params, 3, sprintf('time: %d, agent %d: no meetings set in normal mode', time, iAgent));
            continue;
        end
        
        if agents(iAgent).m1_remTime <= 0
            [agents, commHistory] = meeting(iAgent, agents(iAgent).meetings(1,1), agents, commHistory, params, time);
        end
        
        if isempty(agents(iAgent).meetings)
            logger(params, 3, sprintf('time: %.2d, agent %d: no meetings set in normal mode', time, iAgent));
            continue;
        end
        
        remDist = pdist([agents(iAgent).meetings(1,2), agents(iAgent).meetings(1,3); agents(iAgent).vPosition], 'euclidean');
        
        if ((agents(iAgent).m1_remTime)*agents(iAgent).speed > (stepSize+remDist)) && ~agents(iAgent).moveToMeeting
            %%% if agent has time to explore
            [agents(iAgent).vPosition, agents(iAgent).vTheta, agents(iAgent).position] = getNewPosition(agents(iAgent), 'None', stepSize, regions, mapping);
        else
            [agents(iAgent).vPosition, agents(iAgent).vTheta, agents(iAgent).position] = getNewPosition(agents(iAgent), agents(iAgent).meetings(1,2:3), stepSize, regions, mapping);
            agents(iAgent).moveToMeeting = 1;
        end
        
        agents(iAgent).m1_remTime = agents(iAgent).meetings(1,4) - time;
        agents(iAgent).note = '';
        
    elseif strcmp(agents(iAgent).mode, 'recovery')
        
        nextPositionCalculated = 0;
        
        if ~isempty(agents(iAgent).meetings)
            if agents(iAgent).meetings(1,4)-time <= 0
                
                [agents, commHistory] = meeting(iAgent, agents(iAgent).meetings(1,1), agents, commHistory, params, time);
                
            elseif agents(iAgent).meetings(1,4)-time < 1.1*abs(agents(iAgent).meetings(1,2) - agents(iAgent).vPosition(1))/agents(iAgent).speed
                
                [agents(iAgent).vPosition, agents(iAgent).vTheta, agents(iAgent).position] = getNewPosition(agents(iAgent), agents(iAgent).meetings(2:3), stepSize, regions, mapping);
                nextPositionCalculated = 1;
            end
        end
        
        if agents(iAgent).m2_num == 0
            dbstop if warning;
            warning('revoery mode: no neighbors in recovery list');
        end
        
        agents(iAgent).note = sprintf('recovery search: agents=(%s), timeouts=(%s)', sprintf('%d,',agents(iAgent).m2_neighbor), sprintf('%.2f,',agents(iAgent).m2_remTime));
        
        for n=1:agents(iAgent).m2_num
            if pdist([agents(agents(iAgent).m2_neighbor(n)).vPosition; agents(iAgent).vPosition]) <= 2*agents(iAgent).commRange
                logger(params, 1, sprintf('time: %.2d, agent %d meets agent %d in recovery mode', time, iAgent, agents(iAgent).m2_neighbor(n)));
                
                [agents, commHistory] = meeting_recovery(iAgent, agents(iAgent).m2_neighbor(n), agents, commHistory, params, time);
                
                if n>=agents(iAgent).m2_num
                    break;
                end
            end
            
            if agents(iAgent).m2_remTime(n) <= 0
                y = agents(iAgent).m2_neighbor(n);
                x = iAgent;
                
                agents(x).agents = agents(x).agents(agents(x).agents ~= y);
                
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
                    
                    break;
                end
                
                newNeighbors = get_neighbors(agents(x).agents, x);
                agents(x).neighbors = newNeighbors;
                
                if y>x && newNeighbors(end)>x
                    newNeighbor = newNeighbors(end);
                elseif y<x && newNeighbors(1)<x
                    newNeighbor = newNeighbors(1);
                else
                    newNeighbor = [];
                end
                
                agents(x).vLimit(1) = min(agents(x).vLimit(1), agents(y).vLimit(1));
                agents(x).vLimit(2) = max(agents(x).vLimit(2), agents(y).vLimit(2));
                agents(x).vPartition = [agents(x).vLimit(1) 0;
                    agents(x).vLimit(2) 0 ;
                    agents(x).vLimit(2) agents(x).vPartition(3,2);
                    agents(x).vLimit(1) agents(x).vPartition(3,2);
                    agents(x).vLimit(1) 0];
                
                if ~isempty(newNeighbor)
                    agents(x).m2_remTime(n) = (9 * (agents(x).vLimit(2) - agents(x).vLimit(1)) / agents(x).speed);
                    agents(x).m2_neighbor(n) = newNeighbor;
                else
                    agents(x).mode = 'normal';
                end
            end
            
            agents(iAgent).m2_remTime(n) = agents(iAgent).m2_remTime(n)-dT;
        end
        
        if nextPositionCalculated == 0
            [agents(iAgent).vPosition, agents(iAgent).vTheta, agents(iAgent).position] = getNewPosition(agents(iAgent), 'None', stepSize, regions, mapping);
        end
        
    elseif strcmp(agents(iAgent).mode, 'single')
        agents(iAgent).note = 'single agent';
        [agents(iAgent).vPosition, agents(iAgent).vTheta, agents(iAgent).position] = getNewPosition(agents(iAgent), 'None', stepSize, regions, mapping);
    end
    
    agents(iAgent).midPosition = map_virtual_pt(mean(agents(iAgent).vPartition(2:end,:)), regions, mapping);
    
    for vertexId = 1:size(agents(iAgent).vPartition, 1)
        agents(iAgent).partition(vertexId, :) = map_virtual_pt( agents(iAgent).vPartition(vertexId,:), regions, mapping );
    end
end

end

function [vpos_, vtheta_, pos_] = getNewPosition(agent, headingPt, stepSize, regions, mapping)

if isequal(headingPt, 'None') && strcmp(agent.mode, 'recovery')
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