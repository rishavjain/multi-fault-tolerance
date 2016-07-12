function cb_pausesimulation(source,~)

if sim_paused()
    sim_paused(0);
    set(source, 'String', 'Pause Simulation');
else
    sim_paused(1);
    set(source, 'String', 'Resume Simulation');
end

end