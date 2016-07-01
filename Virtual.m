
% ResetVirtualEnvironment();

global NumberOfAgents A;

marker = 0;
% InitialPartitionWidth = 20;

%%% set the virtual partitions
for agentId = 1:NumberOfAgents
    A(agentId).VirtualPartition.Start = marker;
    marker = marker + 20;
    A(agentId).VirtualPartition.End = marker;
end

global TotalVirtualLength;
TotalVirtualLength = marker;
clear marker;

global VirtualHeight
VirtualHeight = 0.4 * TotalVirtualLength;

%%% draw LOC
% plot([0 TotalVirtualLength], [VirtualHeight/2, VirtualHeight/2], ':');

%%% draw partitions
for agentId = 1:NumberOfAgents
    A(agentId).isLive = 1;
    
    A(agentId).VirtualPartition.Partition = [A(agentId).VirtualPartition.Start, A(agentId).VirtualPartition.End, ...
        A(agentId).VirtualPartition.End, A(agentId).VirtualPartition.Start, A(agentId).VirtualPartition.Start;0, 0, VirtualHeight, VirtualHeight, 0]';
%     A(agentId).VirtualPartition.handleFill = fill(A(agentId).VirtualPartition.Partition(:,1), ...
%         A(agentId).VirtualPartition.Partition(:,2), 'white');
%     
%     plot([A(agentId).VirtualPartition.Start, A(agentId).VirtualPartition.End], [VirtualHeight/2, VirtualHeight/2], ':', ...
%         'LineWidth', 3, 'Color', 'red');
%     
%     A(agentId).VirtualPartition.handleText = text(mean([A(agentId).VirtualPartition.Start, A(agentId).VirtualPartition.End]), ...
%         VirtualHeight/2, num2str(agentId), ...
%         'BackgroundColor', 'white', 'FontSize', 15, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');       
end

clear agentId height;