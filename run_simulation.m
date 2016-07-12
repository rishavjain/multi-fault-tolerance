params = config();

envRegions = inflate_path(params);

[partitions, vPartitions, mapping] = create_partitions(params, envRegions);

agents = initialize_agents(params, envRegions, partitions, vPartitions, mapping);

time = 0;
dT = params.sim.timestep;

draw_env(params, envRegions, partitions, agents, 'new');
draw_agents(params, agents, envRegions, mapping, 'new');
create_interactive(params, agents, time, dT, 'new');
drawnow;

tic;
while time<params.sim.maxtime
    
    if ~ishandle(params.fig1handle)
        return;
    end
    
    if sim_paused()
        pause(0.1);
        continue;
    end
    
    if sim_debug() < time
        sim_debug(Inf);
        dbstop if warning;
        warning('pausing for debug at time=%.2f', time);
    end
    
    if toc > dT
        tic;
        
        agents = move_agents(agents, dT, envRegions, mapping, params, time);
        
        if sim_agents_to_kill()            
            for k=sim_agents_to_kill()
                if find([agents.id] == k)
                    agents(k).isAlive = 0;
                    agents(k).position = [1000,0];
                end
            end
            sim_agents_to_kill([]);
        end
        
        speedChanged = sim_speedchanged();
        if speedChanged
            for iAgent = 1:length(agents)
                agents(iAgent).speed = speedChanged;
            end
        end
        clear speedChanged iAgent;
        
        time = time + dT;
        
        draw_env(params, envRegions, partitions, agents, 'update');
        draw_agents(params, agents, envRegions, mapping, 'update');
        create_interactive(params, agents, time, dT, 'update');
        drawnow;
    end
end

finish(params)
