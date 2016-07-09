function create_interactive(params, agents, time, dT, action)

persistent timeTable agentsTable;

if strcmp(action, 'new')
    panel = uipanel('Parent', params.fig1handle, 'BackgroundColor','white', 'Position', [0.01, 0.01, 0.4, 0.98]);
    
    killButton = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Kill Agent', ...
        'Units', 'normalized', 'Position', [0.2, 0.05, 0.1, 0.05], 'Callback', @cb_killagent);
    
    if sim_paused()
        pauseStr = 'Resume Simulation';
    else
        pauseStr = 'Pause Simulation';
    end
    
    resumeButton = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', pauseStr, ...
        'Units', 'normalized', 'Position', [0.05, 0.05, 0.1, 0.05], 'Callback', @cb_pausesimulation);
    
    debugButton = uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', 'Pause to DEBUG', ...
        'Units', 'normalized', 'Position', [0.35, 0.05, 0.1, 0.05], 'Callback', @cb_debugagent);
    
    speedText = uicontrol('Parent', panel, 'Style', 'text', 'BackgroundColor', 'white', ...
        'Units', 'normalized', 'Position', [0.55, 0.075, 0.3, 0.025], 'String', 'Speed');
    
    speedSlider = uicontrol('Parent', panel, 'Style', 'slider', 'Min', 1, 'Max', 150,'Value', agents(1).speed, ...
        'Units', 'normalized', 'Position', [0.65, 0.05, 0.3, 0.015], 'Callback', @cb_speedslider);
    
    align([killButton, resumeButton, debugButton, speedSlider], 'Distribute', 'None');
    align([speedText, speedSlider], 'Center', 'Distribute');
    
    timePanel = uipanel('Parent', panel, 'Title', 'Time', 'FontSize', 12, 'BackgroundColor','white', 'Position', [0.05, 0.85, 0.85, 0.15]);
    timeTable = uitable('Parent', timePanel, 'RowName', {'time';'dT'}, 'Data', [time; dT], 'ColumnName', [], ...
        'Units', 'normalized', 'Position', [0.35, 0.05, 0.3, 0.95], 'FontSize', 12);
    
    data = cell(length(agents), 4);
    for iAgent = 1:length(agents)
        data(iAgent,:) = {num2str(iAgent), ...
            sprintf('%.2f', agents(iAgent).meetings(1,1)), ...
            sprintf('%.2f', agents(iAgent).meetings(1,4)), ...
            agents(iAgent).note};
    end
    
    meetingPanel = uipanel('Parent', panel, 'Title', 'Meeting', 'FontSize', 12, 'BackgroundColor','white', 'Position', [0.05, 0.15, 0.85, 0.7]);
    agentsTable = uitable('Parent', meetingPanel, 'Data', data, 'RowName', [], 'ColumnName', {'Agent'; 'Meet Agent'; 'Time';''}, ...
        'Units', 'normalized', 'Position', [0.02, 0.02, 0.96, 0.96], 'FontSize', 12, 'ColumnWidth', {80, 80, 80, 360});
    
elseif strcmp(action, 'update')
    set(timeTable, 'Data', [time; dT]);
    
    data = cell(0,4);
    idx = 1;
    for iAgent = 1:length(agents)
        if agents(iAgent).isAlive
            if ~isempty(agents(iAgent).meetings)
                for iMeeting = 1:size(agents(iAgent).meetings, 1)
                    meeting = agents(iAgent).meetings(iMeeting, :);
                    data(idx,:) = {num2str(iAgent), ...
                        sprintf('%.2f', meeting(1)), ...
                        sprintf('%.2f', meeting(4)), ...
                        agents(iAgent).note};
                        idx = idx + 1;
                end
            elseif ~strcmp(agents(iAgent).note, '')
                data(idx,:) = {num2str(iAgent), '-', '-', agents(iAgent).note};
                idx = idx + 1;
            else
                logger(params, 3, sprintf('time: %.2f, agent %d has no meeting and no note', time, iAgent));
            end            
        end
    end
    
    set(agentsTable, 'Data', data);
end
end
