function UI_KillAgent(source,callbackdata)

global Agents KILL_AGENT

% [x,y] = ginput(1);
% 
% for i=1:length(Agents)
%     if inpolygon(x, y, Agents(i).polygon(:,1), Agents(i).polygon(:,2))~=0
%         KILL_AGENT = i;
%     end
% end

input = inputdlg('Agent to kill');

if isempty(input)
    return
end

input = str2num(cell2mat(input));

if isempty(input)
    return
end

for i=input
    if find([Agents.ID] == i)
        KILL_AGENT = [KILL_AGENT, find([Agents.ID] == i)];
    end
end

end