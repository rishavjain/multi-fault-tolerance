function [ partitions, vPartitions, mapping ] = create_partitions( params, regions )

nAgents = params.agents.num;
inflationSize = params.env.inflationSize;

totalArea = get_total_area(regions);
logger(params, 1, sprintf('totalArea: %d', totalArea));

unitArea = 2*inflationSize;

mapping = [];
revMapping = [];
pivotValues = [];

areaUsed = 0;
for iRegion = 1:length(regions)
    mapping = [mapping; areaUsed, areaUsed + (regions(iRegion).area/unitArea), iRegion]; % start-length, end-length, region-mapped
    areaUsed = areaUsed + (regions(iRegion).area/unitArea);
    
    revMapping = [revMapping, min(regions(iRegion).polygon(:,1)), max(regions(iRegion).polygon(:,1)), min(regions(iRegion).polygon(:,2)), max(regions(iRegion).polygon(:,2)), iRegion];
    
    if isequal(class(regions(iRegion)), 'turnregion')
        pivotValues = [pivotValues; mean(mapping(iRegion,1:2)), iRegion];
    end
end

partitions = cell(1,nAgents);
vPartitions = cell(1,nAgents);

vMarker = 0;
for iAgent = 1:nAgents
    vLength = totalArea/(nAgents*unitArea);
    vHeight = unitArea;
    
    vPartition = [vMarker, 0;
        vMarker+vLength 0;
        vMarker+vLength vHeight;
        vMarker vHeight;
        vMarker, 0];
    
    partition = zeros(size(vPartition));
    
    for vertexId = 1:size(vPartition, 1)
        pt = vPartition(vertexId,:);
        regionIndex = find(mapping(:,1) <= pt(1), 1, 'last');
        
        [mappedX, mappedY] = regions(regionIndex).mapVPt(pt(1), pt(2), mapping(regionIndex,:));
        
        partition(vertexId, :) = [mappedX, mappedY];
    end
    
    
    partitions(iAgent) = {partition};
    vPartitions(iAgent) = {vPartition};
    
    vMarker = vMarker + vLength;
    
    %%%----------TESTING----------------------------------------------------
    figure(1);
    hold on;
%     axis([-30 30 -30 30]);
    axis equal;
    grid on;
    grid minor;
    plot(vPartition(:,1), vPartition(:,2));
    figure(2);
    hold on;
%     axis([-30 30 -30 30]);
    axis equal;
    grid on;
    grid minor;
    plot(partition(:,1), partition(:,2));
    
    tmpmeshx = vMarker-vLength:vMarker;
    tmpmeshy = ones(size(tmpmeshx)) .* vHeight*0.5;
    
    if ~exist('tmpn', 'var')
    tmpn = 1;
    end
    
    for i=1:size(tmpmeshx,2)
        
            pt = [tmpmeshx(i), tmpmeshy(i)];
            
            regionIndex = find(mapping(:,1) <= pt(1), 1, 'last');
            
            [mappedX, mappedY] = regions(regionIndex).mapVPt(pt(1), pt(2), mapping(regionIndex,:));
            
            [revmappedX, revmappedY] = regions(regionIndex).revMapVPt(mappedX, mappedY, mapping(regionIndex,:));
            %             figure(1)
            %             text(pt(1), pt(2), num2str(tmpn), 'HorizontalAlignment', 'center');
            
            if abs(pt(1) - revmappedX) > 1e-5 || abs(pt(2) - revmappedY) > 1e-5
                %                 error 'mapping and reverse mapping not matched'
                logger(params, 1, sprintf('incorrect region:%d [%3d %3d] <--> [%3d %3d]', regionIndex, pt, revmappedX, revmappedY));
            else
                logger(params, 1, sprintf('correct region:%d [%3d %3d] <--> [%3d %3d]', regionIndex, pt, revmappedX, revmappedY));
            end
            
            figure(2)
            text(mappedX, mappedY, num2str(tmpn), 'HorizontalAlignment', 'center', 'FontSize', 5);
            
            tmpn = tmpn + 1;
        
    end
    
%     if iAgent == 2
%         break;
%     end
    %%%------------------------------------------------------------------------
end

end

function [area] = get_total_area(regions)
area = 0;

for iRegion = 1:length(regions)
    area = area + regions(iRegion).area;
end
end