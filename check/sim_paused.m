function [ isPaused ] = sim_paused(pause)

persistent isPaused_;

if isempty(isPaused_)
    isPaused_ = 1;
end

if exist('pause', 'var')
    isPaused_ = pause;   
end

isPaused = isPaused_;
end
