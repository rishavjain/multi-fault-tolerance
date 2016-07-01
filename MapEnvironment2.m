
ResetActualEnvironment();

Environment = [0, 0; 100, 0; 100, 30; 30, 30; 30, 100; 100, 100; 100, 130; 0, 130; 0, 0];

fill(Environment(:,1), Environment(:,2), 'white');

TotalArea = polyarea(Environment(:,1), Environment(:,2));

global TotalVirtualLength;
UnitArea = TotalArea / TotalVirtualLength;

% StartPoints = [100, 100; 100, 130];

global NumberOfAgents A;
for agentId = 1:NumberOfAgents
    if A(agentId).isLive ~= 1
        continue;       
    end
    
    inLen1 = pdist([Environment(6,:);Environment(5,:)]);
    inLen2 = pdist([Environment(5,:);Environment(4,:)]);
    inLen3 = pdist([Environment(4,:);Environment(3,:)]);
    
    startInner = A(agentId).VirtualPartition.Start*(inLen1+inLen2+inLen3)/TotalVirtualLength;
    
    if startInner > inLen1+inLen2
        startInner = [Environment(4,1) + (startInner - (inLen1+inLen2)), Environment(4,2)];
    elseif startInner > inLen1
        startInner = [Environment(5,1), Environment(5,2) - (startInner - inLen1)];
    else
        startInner = [Environment(6,1) - (startInner), Environment(6,2)];
    end
        
    endInner = A(agentId).VirtualPartition.End*(inLen1+inLen2+inLen3)/TotalVirtualLength;
    
    if endInner > inLen1+inLen2
        endInner = [Environment(4,1) + (endInner - (inLen1+inLen2)), Environment(4,2)];
    elseif endInner > inLen1
        endInner = [Environment(5,1), Environment(5,2) - (endInner - inLen1)];
    else
        endInner = [Environment(6,1) - (endInner), Environment(6,2)];
    end
    
    if startInner(1) ~= endInner(1) && startInner(2) ~= endInner(2)
        if pdist([mean([startInner;endInner]);Environment(4,:)]) < pdist([mean([startInner;endInner]);Environment(5,:)])
            startInner = [startInner;Environment(4,:)];
        else
            startInner = [startInner;Environment(5,:)];
        end
    end
    
    outLen1 = pdist([Environment(7,:);Environment(8,:)]);
    outLen2 = pdist([Environment(8,:);Environment(1,:)]);
    outLen3 = pdist([Environment(1,:);Environment(2,:)]);
    
    startOuter = A(agentId).VirtualPartition.Start*(outLen1+outLen2+outLen3)/TotalVirtualLength;
    
    if startOuter > outLen1+outLen2
        startOuter = [Environment(1,1) + (startOuter - (outLen1+outLen2)), Environment(1,2)];
    elseif startOuter > outLen1
        startOuter = [Environment(8,1), Environment(8,2) - (startOuter - outLen1)];
    else
        startOuter = [Environment(7,1) - (startOuter), Environment(7,2)];
    end
    
    endOuter = A(agentId).VirtualPartition.End*(outLen1+outLen2+outLen3)/TotalVirtualLength;
    
    if endOuter > outLen1+outLen2
        endOuter = [Environment(1,1) + (endOuter - (outLen1+outLen2)), Environment(1,2)];
    elseif endOuter > outLen1
        endOuter = [Environment(8,1), Environment(8,2) - (endOuter - outLen1)];
    else
        endOuter = [Environment(7,1) - (endOuter), Environment(7,2)];
    end
    
    if startOuter(1) ~= endOuter(1) && startOuter(2) ~= endOuter(2)
        if pdist([mean([startOuter;endOuter]);Environment(1,:)]) < pdist([mean([startOuter;endOuter]);Environment(8,:)])
            endOuter = [endOuter;Environment(1,:)];
        else
            endOuter = [endOuter;Environment(8,:)];
        end
    end
    
    A(agentId).ActualParition.Partition = [startInner; endInner; endOuter; startOuter; startInner];
    A(agentId).ActualParition.Area = polyarea(A(agentId).ActualParition.Partition(:,1), A(agentId).ActualParition.Partition(:,2));
    A(agentId).ActualParition.handleFill = fill(A(agentId).ActualParition.Partition(:,1), A(agentId).ActualParition.Partition(:,2), ...
        'white', 'FaceAlpha', 0);
    A(agentId).ActualParition.handleText = text(mean(A(agentId).ActualParition.Partition(1:end-1,1)), ...
        mean(A(agentId).ActualParition.Partition(1:end-1,2)), num2str(agentId), ...
        'BackgroundColor', 'white', 'FontSize', 15, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end
