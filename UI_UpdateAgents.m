function Agents = UI_UpdateAgents(Agents)

global A partitionH CR_X CR_Y Mapping Regions

UI_UpdatePartitions();

for i=1:length(Agents)
%     set(Agents(i).H.polygon, 'XData', actualPartition(:,1), 'YData', actualPartition(:,2));
%     set(Agents(i).H.poly_text, 'Position', [mean(Agents(i).x_limit), partitionH/2]);
%     set(Agents(i).H.ext_text, 'Position', [Agents(i).x_limit(1)+1, partitionH]);    

    regionIndex = find(Mapping(:,1) <= Agents(i).position(1), 1, 'last');
    [positionX, positionY] = Regions(regionIndex).mapVirtualPoint(Agents(i).position(1), Agents(i).position(2), Mapping(regionIndex,:));
    set(Agents(i).H.CR, 'X', CR_X + positionX, 'Y', CR_Y + positionY);
    set(Agents(i).H.robot, 'X', positionX, 'Y', positionY);
end

end