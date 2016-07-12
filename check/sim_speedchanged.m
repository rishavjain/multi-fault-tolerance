function [ speed ] = sim_speedchanged(speedChanged)

persistent speedChanged_;

if exist('speedChanged', 'var')
    speedChanged_ = speedChanged;   
end

speed = [];

if isempty(speedChanged_)
    speedChanged_ = [];
elseif exist('speedChanged', 'var')
    speedChanged_ = speedChanged;
else
    speed = speedChanged_;
    speedChanged_ = [];
end

end
