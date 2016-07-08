classdef region < matlab.mixin.Heterogeneous
    %REGION Summary of this class goes here
    %   Detailed explanation goes here
    
    % region: (in direction theta=0)
    %   s2-----e2
    %   |      |
    %   |      |
    %   s1-----e1
    
    properties
        s1
        e1
        s2
        e2
        
        type
        area
        polygon
    end    
    
    methods
%        function [x_, y_] = mapVirtualPoint(obj, x, y, mapping)
%            x_ = nan;
%            y_ = nan;
%        end
    end
        
end
