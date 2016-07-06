classdef StraightRegion < Region
    %STRAIGHTREGION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        length
        width
        direction
    end
    
    methods
        function obj = StraightRegion(inStartPoint, outStartPoint, inEndPoint, outEndPoint)
            obj.inStartPoint = inStartPoint;
            obj.inEndPoint = inEndPoint;
            obj.outStartPoint = outStartPoint;
            obj.outEndPoint = outEndPoint;
            
            obj.type = 'straight';
            
            obj.length = pdist([inStartPoint;inEndPoint]);
            obj.width = pdist([inStartPoint;outStartPoint]);
            
            obj.area = obj.length * obj.width;
            obj.direction = atan2(inEndPoint(2) - inStartPoint(2), inEndPoint(1) - inStartPoint(1));
            
            obj.polygon = [obj.inStartPoint; obj.inEndPoint; obj.outEndPoint; obj.outStartPoint; obj.inStartPoint];
            
            if pdist([inStartPoint;outStartPoint]) ~= pdist([inEndPoint;outEndPoint])
                error 'StraightRegion : unequal width'
            elseif pdist([inStartPoint;inEndPoint]) ~= pdist([outStartPoint;outEndPoint])
                error 'StraightRegion : unequal length'
            end
        end
        
        function [x_, y_] = mapVirtualPoint(obj, x, y, mapping)
            global VirtualHeight;            
            xdirection = atan2(obj.inEndPoint(2)-obj.inStartPoint(2), obj.inEndPoint(1)-obj.inStartPoint(1));
            xScale = obj.length / (mapping(2) - mapping(1));
            x = x - mapping(1);
            x_ = obj.inStartPoint(1) + x*xScale*cos(xdirection);
            y_ = obj.inStartPoint(2) + x*xScale*sin(xdirection);
            
            ydirection = atan2(obj.outStartPoint(2)-obj.inStartPoint(2), obj.outStartPoint(1)-obj.inStartPoint(1));
            yScale = obj.width / VirtualHeight;
            x_ = x_ + y*yScale*cos(ydirection);
            y_ = y_ + y*yScale*sin(ydirection);
        end
        
        function [x_, y_] = revMapVirtualPoint(obj, x, y, mapping)
            global VirtualHeight;            
            xdirection = atan2(obj.inEndPoint(2)-obj.inStartPoint(2), obj.inEndPoint(1)-obj.inStartPoint(1));
            xScale = obj.length / (mapping(2) - mapping(1));
            x_ = mapping(1) + (x - obj.inStartPoint(1))/(xScale*cos(xdirection));
            y_ = mapping(1) + (x - obj.inStartPoint(2))/(xScale*sin(xdirection));
            
            ydirection = atan2(obj.outStartPoint(2)-obj.inStartPoint(2), obj.outStartPoint(1)-obj.inStartPoint(1));
            yScale = VirtualHeight / obj.width;
            x_ = x_ + y*yScale*cos(ydirection);
            y_ = y_ + y*yScale*sin(ydirection);
        end
        
        function handle = drawpolygon(obj)
            handle = fill(obj.polygon(:,1), obj.polygon(:,2), 'yellow', 'FaceAlpha', 0.2, 'EdgeColor', 'None');
        end
    end
    
end
