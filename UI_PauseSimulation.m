function UI_KillAgent(source,callbackdata)

global PAUSE_SIMULATION
PAUSE_SIMULATION = ~PAUSE_SIMULATION;

if PAUSE_SIMULATION == 1
    set(source, 'String', 'Resume');
else
    set(source, 'String', 'Pause');
end

end