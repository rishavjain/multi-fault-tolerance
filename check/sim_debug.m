function [ debug_time ] = sim_debug(time)

persistent debug_time_;

if isempty(debug_time_)
    debug_time_ = Inf;
end

if exist('time', 'var')
    debug_time_ = time;   
end

debug_time = debug_time_;
end
