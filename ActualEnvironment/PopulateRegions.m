
ResetEnvironment;

global Regions
Regions = [];
Regions = [Regions, StraightRegion([15 0], [0 0], [15 20], [0 20])];
Regions = [Regions, TurnRegion([15 20], [0 20], [15 20], [15 35])];
Regions = [Regions, StraightRegion([15 20], [15 35], [35 20], [35 35])];
Regions = [Regions, TurnRegion([35 20], [35 35], [35 20], [50 20])];
Regions = [Regions, StraightRegion([35 20], [50 20], [35 0], [50 0])];
Regions = [Regions, TurnRegion([35 0], [50 0], [50 -15], [50 0])];
Regions = [Regions, StraightRegion([50 -15], [50 0], [70 -15], [70 0])];
Regions = [Regions, TurnRegion([70 -15], [70 0], [85 0], [70 0])];
Regions = [Regions, StraightRegion([85 0], [70 0], [85 20], [70 20])];

% Regions = [Regions, StraightRegion([100 100], [100 130], [30 100], [30 130])];
% Regions = [Regions, TurnRegion([30 100], [30 130], [30 100], [0 100])];
% Regions = [Regions, StraightRegion([30 100], [0 100], [30 30], [0 30])];
% Regions = [Regions, TurnRegion([30 30], [0 30], [30 30], [30 0])];
% Regions = [Regions, StraightRegion([30 30], [30 0], [100 30], [100 0])];


TotalArea = 0;
for regionIndex = 1:length(Regions)
    region = Regions(regionIndex);
    region.drawPolygon();
    TotalArea = TotalArea + region.Area;
end

global TotalVirtualLength;
UnitArea = TotalArea/TotalVirtualLength;

global Mapping;
Mapping = [];
global PivotValues;
PivotValues = [];

AreaUsed = 0;
for regionIndex = 1:length(Regions)
    Mapping = [Mapping; AreaUsed, AreaUsed + (Regions(regionIndex).Area/UnitArea), regionIndex];
    AreaUsed = AreaUsed + (Regions(regionIndex).Area/UnitArea);
    
    if isequal(class(Regions(regionIndex)), 'TurnRegion')
        PivotValues = [PivotValues; mean(Mapping(regionIndex,1:2)), regionIndex];
    end
end

global A NumberOfAgents;
for agentId=1:NumberOfAgents    
    actualPartition = [];    
    suspectedIndices = [];
    
    for vertexId = 1:size(A(agentId).VirtualPartition.Partition, 1)
        pt = A(agentId).VirtualPartition.Partition(vertexId,:);
        regionIndex = find(Mapping(:,1) <= pt(1), 1, 'last');
        
        [mappedX, mappedY] = Regions(regionIndex).mapVirtualPoint(pt(1), pt(2), Mapping(regionIndex,:));
        
        actualPartition = [actualPartition; [mappedX, mappedY]];
    end
    
    A(agentId).VirtualPartition.handleFill = fill(actualPartition(:,1), actualPartition(:,2), 'w', 'FaceAlpha', 0);
% A(agentId).VirtualPartition.handleFill = plot([actualPartition(4:5,1) actualPartition(2:3,1)], [actualPartition(4:5,2) actualPartition(2:3,2)], 'k');
    
    %{
    global VirtualHeight;
    for i=A(agentId).VirtualPartition.Start:10:A(agentId).VirtualPartition.End
        for j=0:20:VirtualHeight
            regionIndex = find(Mapping(:,1) <= i, 1, 'last');
            [mappedX, mappedY] = Regions(regionIndex).mapVirtualPoint(i, j, Mapping(regionIndex,:));
            plot(mappedX, mappedY, '.r', 'MarkerSize', 6+j/15);
        end
    end
    %}
end

