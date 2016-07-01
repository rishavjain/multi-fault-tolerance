function [] = UI_UpdatePartitions()

global A Agents NumberOfAgents Mapping Regions PivotValues VirtualHeight;
for agentId=1:NumberOfAgents    
    actualPartition = [];
    
%     suspectedIndices = [];
    for vertexId = 1:size(Agents(agentId).polygon, 1)
        pt = Agents(agentId).polygon(vertexId,:);
        regionIndex = find(Mapping(:,1) <= pt(1), 1, 'last');
        
        [mappedX, mappedY] = Regions(regionIndex).mapVirtualPoint(pt(1), pt(2), Mapping(regionIndex,:));
        
        actualPartition = [actualPartition; [mappedX, mappedY]];
                
%         if Regions(regionIndex).Type == RegionType.TURN && vertexId < size(Agents(agentId).polygon, 1)
%             if pdist([[mappedX, mappedY]; Regions(regionIndex).PivotPoint]) > 0.001
%                 suspectedIndices = [suspectedIndices, vertexId];
%             end
%         end
    end
    
    %{
    if ~isempty(suspectedIndices)
        if length(suspectedIndices) == 2
            if suspectedIndices(1) < suspectedIndices(2)
                index1 = suspectedIndices(1);
                index2 = suspectedIndices(2);
            else
                index1 = suspectedIndices(2);
                index2 = suspectedIndices(1);
            end
            
            if abs(index1 - index2) == 1
                pt1 = Agents(agentId).polygon(index1,:);
                pt2 = Agents(agentId).polygon(index2,:);
                
                if find(Mapping(:,1) <= pt1(1), 1, 'last') == find(Mapping(:,1) <= pt2(1), 1, 'last')
                    regionIndex = find(Mapping(:,1) <= pt1(1), 1, 'last');
%                     pt1 = actualPartition(index1, :);
%                     pt2 = actualPartition(index2, :);
%                     meanPt = mean([pt1;pt2]);
                    actualPartition = [actualPartition(1:index1,:); Regions(regionIndex).ExtraDrawPoint; actualPartition(index2:end,:)];
                end
            end
        else
            if suspectedIndices-1 > 0
                pt1 = Agents(agentId).polygon(suspectedIndices-1, :);
                pt2 = Agents(agentId).polygon(suspectedIndices, :);
                
                for pivotValue = PivotValues'
                    if (pt1(1)-pivotValue)*(pt2(1)-pivotValue) < 0
                        regionIndex = find(Mapping(:,1) <= pt2(1), 1, 'last');
%                         pt1 = actualPartition(suspectedIndices-1, :);
%                         pt2 = actualPartition(suspectedIndices, :);
%                         meanPt = mean([pt1;pt2]);
                        actualPartition = [actualPartition(1:suspectedIndices,:); Regions(regionIndex).ExtraDrawPoint; actualPartition(suspectedIndices+1:end,:)];
                        break;
                    end
                end
                
            end
            if suspectedIndices+1 < 6
                pt1 = Agents(agentId).polygon(suspectedIndices, :);
                pt2 = Agents(agentId).polygon(suspectedIndices+1, :);
                
                for pivotValue = PivotValues'
                    if (pt1(1)-pivotValue)*(pt2(1)-pivotValue) < 0
                        regionIndex = find(Mapping(:,1) <= pt1(1), 1, 'last');
%                         pt1 = actualPartition(suspectedIndices, :);
%                         pt2 = actualPartition(suspectedIndices+1, :);
%                         meanPt = mean([pt1;pt2]);
                        actualPartition = [actualPartition(1:suspectedIndices,:); Regions(regionIndex).ExtraDrawPoint; actualPartition(suspectedIndices+1:end,:)];
                        break;
                    end
                end
            end
        end
    end
        %}
%     if isvalid(Agents(agentId).H.polygon)
% set(Agents(agentId).H.polygon, 'XData', actualPartition(:,1), 'YData', actualPartition(:,2));

polygon = Agents(agentId).polygon;
while 1
    newActualPartition = actualPartition;
    for vertexId = size(actualPartition,1)-1:-1:1
        pt1 = polygon(vertexId,:);
        pt2 = polygon(vertexId+1,:);
        
        if pt1(1) == pt2(1)
            continue;
        end
        
        %     count = 0;
        for pivotValue = flipud(PivotValues)'
            if (pt1(1)-pivotValue(1))*(pt2(1)-pivotValue(1)) < 0
                %             if count > 0
                %                 count;
                %             end
                meanPt = mean([pt1;pt2]);
                regionIndex = pivotValue(2);
                
                if pt1(2) == 0
                    if isequal(Regions(regionIndex).PivotPoint, Regions(regionIndex).InnerStartPoint)
                        newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).PivotPoint; newActualPartition(vertexId+1:end,:)];
                        polygon = [polygon(1:vertexId,:); pivotValue(1), 0; polygon(vertexId+1:end,:)];
                    else
                        newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).ExtraDrawPoint; newActualPartition(vertexId+1:end,:)];
                        polygon = [polygon(1:vertexId,:); pivotValue(1), VirtualHeight; polygon(vertexId+1:end,:)];
                    end
                else
                    if isequal(Regions(regionIndex).PivotPoint, Regions(regionIndex).InnerStartPoint)
                        newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).ExtraDrawPoint; newActualPartition(vertexId+1:end,:)];
                        polygon = [polygon(1:vertexId,:); pivotValue(1), VirtualHeight; polygon(vertexId+1:end,:)];
                    else
                        newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).PivotPoint; newActualPartition(vertexId+1:end,:)];
                        polygon = [polygon(1:vertexId,:); pivotValue(1), 0; polygon(vertexId+1:end,:)];
                    end
                end
                
%                 m1 = atan2(actualPartition(vertexId+1,2) - Regions(regionIndex).ExtraDrawPoint(2), actualPartition(vertexId+1,1) - Regions(regionIndex).ExtraDrawPoint(1));
%                 m2 = atan2(Regions(regionIndex).ExtraDrawPoint(2) - actualPartition(vertexId,2), Regions(regionIndex).ExtraDrawPoint(1) - actualPartition(vertexId,1));
%                 
%                 if mod(abs(m1 - m2), pi/2) < 0.001
%                     newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).ExtraDrawPoint; newActualPartition(vertexId+1:end,:)];
%                     if isequal(Regions(regionIndex).ExtraDrawPoint, Regions(regionIndex).InnerStartPoint)
%                         polygon = [polygon(1:vertexId,:); pivotValue(1), 0; polygon(vertexId+1:end,:)];
%                     else
%                         polygon = [polygon(1:vertexId,:); pivotValue(1), VirtualHeight; polygon(vertexId+1:end,:)];
%                     end
%                 else
%                     newActualPartition = [newActualPartition(1:vertexId,:); Regions(regionIndex).PivotPoint; newActualPartition(vertexId+1:end,:)];
%                     if isequal(Regions(regionIndex).ExtraDrawPoint, Regions(regionIndex).InnerStartPoint)
%                         polygon = [polygon(1:vertexId,:); pivotValue(1), VirtualHeight; polygon(vertexId+1:end,:)];
%                     else
%                         polygon = [polygon(1:vertexId,:); pivotValue(1), 0; polygon(vertexId+1:end,:)];
%                     end
%                 end
                break;
                %             count = count + 1;
            end
        end
    end
    
    if isequal(actualPartition, newActualPartition)
        break;
    end
    
    actualPartition = newActualPartition;
end
% set(Agents(agentId).H.polygon(1), 'XData', [actualPartition(4:5,1)], 'YData', [actualPartition(4:5,2)]);
% set(Agents(agentId).H.polygon(2), 'XData', [actualPartition(2:3,1)], 'YData', [actualPartition(2:3,2)]);
set(Agents(agentId).H.polygon, 'XData', actualPartition(:,1), 'YData', actualPartition(:,2));
end


end

