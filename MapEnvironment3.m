
ResetActualEnvironment();

Environment = [0, 0; 100, 0; 100, 30; 30, 30; 30, 100; 100, 100; 100, 130; 0, 130; 0, 0];

fill(Environment(:,1), Environment(:,2), 'white');

TotalArea = polyarea(Environment(:,1), Environment(:,2));

global TotalVirtualLength;
UnitArea = TotalArea / TotalVirtualLength;

Region = struct();
Region(1:5) = struct();

Region(1).Width = pdist([Environment(6,:);Environment(7,:)]);
Region(1).Length = pdist([Environment(6,:);Environment(5,:)]);
Region(1).Area = Region(1).Width*Region(1).Length;

Region(2).Width = pdist([Environment(7,:);Environment(8,:)]) - pdist([Environment(6,:);Environment(5,:)]);
Region(2).Length = Region(1).Width;
Region(2).Area = Region(2).Width*Region(2).Length;

Region(3).Width = Region(2).Width;
Region(3).Length = pdist([Environment(5,:);Environment(4,:)]);
Region(3).Area = Region(3).Width*Region(3).Length;

Region(4).Width = pdist([Environment(3,:);Environment(2,:)]);
Region(4).Length = Region(3).Width;
Region(4).Area = Region(4).Width*Region(4).Length;

Region(5).Width = Region(4).Width;
Region(5).Length = pdist([Environment(4,:);Environment(3,:)]);
Region(5).Area = Region(5).Width*Region(5).Length;

% StartPoints = [100, 100; 100, 130];

areaFilled = 0;

currentOuterPosition = Environment(7,:);
currentInnerPosition = Environment(6,:);

global NumberOfAgents A;
for agentId = 1:NumberOfAgents
    if A(agentId).isLive ~= 1
        continue;       
    end
    
    intendedAreaFill = (A(agentId).VirtualPartition.End - A(agentId).VirtualPartition.Start)*UnitArea;
    
    if areaFilled + intendedAreaFill < Region(1).Area
        
        deltaOuter = [-intendedAreaFill/Region(1).Width, 0];
        deltaInner = deltaOuter;
        nextOuterPosition = currentOuterPosition + deltaOuter;
        nextInnerPosition = currentInnerPosition + deltaInner;
        
    elseif areaFilled + intendedAreaFill < Region(1).Area + Region(2).Area      
        nextInnerPosition = Environment(5,:);
        intendedRegionArea = areaFilled + intendedAreaFill - Region(1).Area;
        
        if intendedRegionArea < Region(2).Area / 2
            deltaOuter = [-2 * intendedRegionArea / Region(2).Length, 0];
            nextOuterPosition = Environment(7,:) + [-Region(1).Length, 0] +  deltaOuter;
        else
            intendedRegionArea = intendedRegionArea - (Region(2).Area / 2);
            deltaOuter = [0, -(2 * intendedRegionArea / Region(2).Width)];
            nextOuterPosition = Environment(8,:) + deltaOuter;
        end
        
    elseif areaFilled + intendedAreaFill < Region(1).Area + Region(2).Area + Region(3).Area
        intendedRegionArea = areaFilled + intendedAreaFill - (Region(1).Area + Region(2).Area);
        
        deltaOuter = [0, -intendedRegionArea/Region(3).Width];
        nextOuterPosition = Environment(8,:) + [0, -Region(2).Length] + deltaOuter;
        
        deltaInner = deltaOuter;
        nextInnerPosition = Environment(5,:) + deltaInner;
        
    elseif areaFilled + intendedAreaFill < Region(1).Area + Region(2).Area + Region(3).Area + Region(4).Area
        nextInnerPosition = Environment(4,:);
        intendedRegionArea = areaFilled + intendedAreaFill - (Region(1).Area + Region(2).Area + Region(3).Area);
        
        if intendedRegionArea < Region(4).Area / 2
            deltaOuter = [0, -2 * intendedRegionArea / Region(4).Length];
            nextOuterPosition = Environment(1,:) + [0,Region(4).Width] +  deltaOuter;
        else
            intendedRegionArea = intendedRegionArea - (Region(4).Area / 2);
            deltaOuter = [2 * intendedRegionArea / Region(4).Width, 0];
            nextOuterPosition = Environment(1,:) + deltaOuter;
        end
    else
        intendedRegionArea = areaFilled + intendedAreaFill - (Region(1).Area + Region(2).Area + Region(3).Area + Region(4).Area);
        
        deltaOuter = [intendedRegionArea/Region(5).Width, 0];
        nextOuterPosition = Environment(1,:) + [Region(4).Length, 0] + deltaOuter;
        
        deltaInner = deltaOuter;
        nextInnerPosition = Environment(4,:) + deltaInner;
    end
    
    if currentInnerPosition(1) ~= nextInnerPosition(1) && currentInnerPosition(2) ~= nextInnerPosition(2)
        pivotPoint = mean([currentInnerPosition;nextInnerPosition]);
        if pdist([pivotPoint;Environment(4,:)]) < pdist([pivotPoint;Environment(5,:)])
            nextInnerPosition = [nextInnerPosition;Environment(4,:)];
        else
            nextInnerPosition = [nextInnerPosition;Environment(5,:)];
        end
    end
    
    if currentOuterPosition(1) ~= nextOuterPosition(1) && currentOuterPosition(2) ~= nextOuterPosition(2)
        pivotPoint = mean([currentOuterPosition;nextOuterPosition]);
        if pdist([pivotPoint;Environment(4,:)]) < pdist([pivotPoint;Environment(5,:)])
            nextOuterPosition = [Environment(1,:);nextOuterPosition];
        else
            nextOuterPosition = [Environment(8,:);nextOuterPosition];
        end
    end
    
    A(agentId).ActualParition.Partition = [currentInnerPosition; currentOuterPosition; nextOuterPosition; nextInnerPosition; currentInnerPosition];
    A(agentId).ActualParition.Area = polyarea(A(agentId).ActualParition.Partition(:,1), A(agentId).ActualParition.Partition(:,2));
    A(agentId).ActualParition.handleFill = fill(A(agentId).ActualParition.Partition(:,1), A(agentId).ActualParition.Partition(:,2), ...
        'white', 'FaceAlpha', 0);
    A(agentId).ActualParition.handleText = text(mean(A(agentId).ActualParition.Partition(1:end-1,1)), ...
        mean(A(agentId).ActualParition.Partition(1:end-1,2)), num2str(agentId), ...
        'BackgroundColor', 'white', 'FontSize', 15, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    
    if size(nextOuterPosition,1) ~= 1
        currentOuterPosition = nextOuterPosition(2,:);
    else
        currentOuterPosition = nextOuterPosition(1,:);
    end
    
    currentInnerPosition = nextInnerPosition(1,:);    
    
    areaFilled = areaFilled + intendedAreaFill;
end
