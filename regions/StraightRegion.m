classdef straightregion < region
    %STRAIGHTREGION Summary of this class goes here
    %   Detailed explanation goes here
        
    properties
        length
        width
        direction
    end
    
    methods
        function obj = straightregion(s1, s2, e1, e2)
            obj.s1 = s1;
            obj.e1 = e1;
            obj.s2 = s2;
            obj.e2 = e2;
            
            obj.type = 'straight';
            
            obj.length = pdist([s1;e1]);
            obj.width = pdist([s1;s2]);
            
            obj.area = obj.length * obj.width;
            obj.direction = atan2(e1(2) - s1(2), e1(1) - s1(1));
            
            obj.polygon = [obj.s1; obj.e1; obj.e2; obj.s2; obj.s1];
            
            if abs(pdist([s1;s2]) - pdist([e1;e2])) > 1e-5
                error 'straightregion : unequal width'
            elseif abs(pdist([s1;e1]) - pdist([s2;e2])) > 1e-5
                error 'straightregion : unequal length'
            end
        end
        
        function [x_, y_] = mapVPt(obj, x, y, mapping)
            xdirection = atan2(obj.e1(2)-obj.s1(2), obj.e1(1)-obj.s1(1));
            xScale = obj.length / (mapping(2) - mapping(1));
            x = x - mapping(1);
            x_ = obj.s1(1) + x*xScale*cos(xdirection);
            y_ = obj.s1(2) + x*xScale*sin(xdirection);
            
            ydirection = atan2(obj.s2(2)-obj.s1(2), obj.s2(1)-obj.s1(1));
            x_ = x_ + y*cos(ydirection);
            y_ = y_ + y*sin(ydirection);
        end
        
        function [x, y] = revMapVPt(obj, x_, y_, mapping)
            xScale = obj.length / (mapping(2) - mapping(1));
            x = dot(([x_ y_] - obj.s1),(obj.e1 - obj.s1))/sqrt((obj.e1 - obj.s1)*(obj.e1 - obj.s1)');
            x = (x / xScale) + mapping(1);
            
            y = dot(([x_ y_] - obj.s1),(obj.s2 - obj.s1))/sqrt((obj.s2 - obj.s1)*(obj.s2 - obj.s1)');
        end
        
        function handle = draw_polygon(obj, color, alpha)
            if ~exist('color', 'var')
                color = 'w';
            end
            
            if ~exist('alpha', 'var')
                alpha = 0.2;
            end
            
            handle = fill(obj.polygon(:,1), obj.polygon(:,2), color, 'FaceAlpha', alpha, 'EdgeColor', 'None');
            plot(obj.polygon(1:2,1), obj.polygon(1:2,2), 'k');
            plot(obj.polygon(3:4,1), obj.polygon(3:4,2), 'k');
        end
    end
    
end
