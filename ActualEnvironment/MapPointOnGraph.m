function [ output_args ] = MapPointOnGraph( input_args )

global A Mapping Regions

for vertexId = 1:size(A(agentId).VirtualPartition.Partition, 1)
    pt = A(agentId).VirtualPartition.Partition(vertexId,:);
    regionIndex = find(Mapping(:,1) <= pt(1), 1, 'last');
    
    [mappedX, mappedY] = Regions(regionIndex).mapVirtualPoint(pt(1), pt(2), Mapping(regionIndex,:));
    
    %         if vertexId > 1
    %             angle = atan2(mappedY - actualPartition(vertexId-1,2), mappedX - actualPartition(vertexId-1,1));
    %             if abs(mod(angle, pi/2)) > 0.0001 && abs(mod(angle, pi/2) - pi/2) > 0.0001
    %                 min_dist = Inf;
    %                 min_pt = [];
    %                 for pivotIndex = 1:size(PivotPoints,1)
    %                     if pdist([PivotPoints(pivotIndex,:);[mappedX, mappedY]]) < min_dist
    %                         min_dist = pdist([PivotPoints(pivotIndex,:);[mappedX, mappedY]]);
    %                         min_pt = PivotPoints(pivotIndex,:);
    %                     end
    %                 end
    % %                 actualPartition = [actualPartition; min_pt];
    %             end
    %         end
    actualPartition = [actualPartition; [mappedX, mappedY]];
    
    %         text(mappedX, mappedY, num2str(agentId));
    %         figure(2);
    %         text(mappedX, mappedY, num2str(agentId));
end

end

