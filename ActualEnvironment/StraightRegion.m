classdef StraightRegion < Region
    %STRAIGHTREGION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Length
        Width
        Direction
    end
    
    methods
        function obj = StraightRegion(InnerStartPoint, OuterStartPoint, InnerEndPoint, OuterEndPoint)
            obj.InnerStartPoint = InnerStartPoint;
            obj.InnerEndPoint = InnerEndPoint;
            obj.OuterStartPoint = OuterStartPoint;
            obj.OuterEndPoint = OuterEndPoint;                                    
            obj.Type = RegionType.STRAIGHT;
            obj.Length = pdist([InnerStartPoint;InnerEndPoint]);
            obj.Width = pdist([InnerStartPoint;OuterStartPoint]);
            obj.Area = obj.Length * obj.Width;
            obj.Direction = atan2(InnerEndPoint(2) - InnerStartPoint(2), InnerEndPoint(1) - InnerStartPoint(1));
            
            obj.Polygon = [obj.InnerStartPoint; obj.InnerEndPoint; obj.OuterEndPoint; obj.OuterStartPoint; obj.InnerStartPoint];
            
            if pdist([InnerStartPoint;OuterStartPoint]) ~= pdist([InnerEndPoint;OuterEndPoint])
                error 'StraightRegion : unequal width'
            elseif pdist([InnerStartPoint;InnerEndPoint]) ~= pdist([OuterStartPoint;OuterEndPoint])
                error 'StraightRegion : unequal length'
            end
        end
        
        function [x_, y_] = mapVirtualPoint(obj, x, y, mapping)
            global VirtualHeight;            
            xDirection = atan2(obj.InnerEndPoint(2)-obj.InnerStartPoint(2), obj.InnerEndPoint(1)-obj.InnerStartPoint(1));
            xScale = obj.Length / (mapping(2) - mapping(1));
            x = x - mapping(1);
            x_ = obj.InnerStartPoint(1) + x*xScale*cos(xDirection);
            y_ = obj.InnerStartPoint(2) + x*xScale*sin(xDirection);
            
            yDirection = atan2(obj.OuterStartPoint(2)-obj.InnerStartPoint(2), obj.OuterStartPoint(1)-obj.InnerStartPoint(1));
            yScale = obj.Width / VirtualHeight;
            x_ = x_ + y*yScale*cos(yDirection);
            y_ = y_ + y*yScale*sin(yDirection);
        end
        
        function handle = drawPolygon(obj)
            handle = fill(obj.Polygon(:,1), obj.Polygon(:,2), 'yellow', 'FaceAlpha', 0.2, 'EdgeColor', 'None');
        end
    end
    
end
