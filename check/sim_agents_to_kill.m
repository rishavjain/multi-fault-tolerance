function [ agents_to_kill ] = sim_agents_to_kill(input)

persistent agents_to_kill_

if isempty(agents_to_kill_)
    agents_to_kill_ = [];
end

if exist('input', 'var')
    agents_to_kill_ = input;   
end

agents_to_kill = agents_to_kill_;
end
