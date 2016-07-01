function UI_DebugAgent(source,callbackdata)

global DEBUG_TIME

% [x,y] = ginput(1);
% 
% for i=1:length(Agents)
%     if inpolygon(x, y, Agents(i).polygon(:,1), Agents(i).polygon(:,2))~=0
%         KILL_AGENT = i;
%     end
% end

input = inputdlg('Debug at Time');
input = str2double(input);

if isempty(input)
    return
end

DEBUG_TIME = input;

end