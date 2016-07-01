classdef TurnRegion < Region
    properties
        Length
        Width
%         PreviousDirection
%         TurnDirection
        PivotPoint
        ExtraDrawPoint        
    end
    
    methods
        function obj = TurnRegion(InnerStartPoint, OuterStartPoint, InnerEndPoint, OuterEndPoint)
            obj.InnerStartPoint = InnerStartPoint;
            obj.InnerEndPoint = InnerEndPoint;
            obj.OuterStartPoint = OuterStartPoint;
            obj.OuterEndPoint = OuterEndPoint;                                    
            obj.Type = RegionType.TURN;
            obj.Length = pdist([InnerStartPoint;OuterStartPoint]);
            obj.Width = pdist([InnerEndPoint;OuterEndPoint]);
            obj.Area = obj.Length * obj.Width;
%             obj.PreviousDirection = PreviousDirection;
%             obj.TurnDirection = TurnDirection;
            
            if isequal(InnerStartPoint,InnerEndPoint)
                obj.PivotPoint = InnerStartPoint;
                angle = atan2(OuterEndPoint(2)-InnerEndPoint(2), OuterEndPoint(1)-OuterEndPoint(1));
                obj.ExtraDrawPoint = [OuterStartPoint(1) + obj.Width*cos(angle), OuterStartPoint(2) + obj.Width*sin(angle)];
                obj.Polygon = [obj.InnerStartPoint; obj.InnerEndPoint; obj.OuterEndPoint; obj.ExtraDrawPoint; obj.OuterStartPoint; obj.InnerStartPoint];
            elseif isequal(OuterStartPoint,OuterEndPoint)     
                obj.PivotPoint = OuterStartPoint;
                angle = atan2(InnerEndPoint(2)-OuterEndPoint(2), InnerEndPoint(1)-OuterEndPoint(1));
                obj.ExtraDrawPoint = [InnerStartPoint(1) + obj.Width*cos(angle), InnerStartPoint(2) + obj.Width*sin(angle)];
                obj.Polygon = [obj.InnerStartPoint; obj.ExtraDrawPoint; obj.InnerEndPoint; obj.OuterEndPoint; obj.OuterStartPoint; obj.InnerStartPoint];
            end
                                    
            if pdist([InnerStartPoint;OuterStartPoint]) ~= pdist([InnerEndPoint;OuterEndPoint])
                error 'TurnRegion : unequal width'
            end
        end
        
        function [x_, y_] = mapVirtualPoint(obj, x, y, mapping)
            actualXScale = obj.Length + obj.Width;
            virtualXScale = mapping(2) - mapping(1);
            
            scaledX = (x - mapping(1)) * actualXScale / virtualXScale;
            
            global VirtualHeight;
            if isequal(obj.PivotPoint, obj.InnerStartPoint)
                pt1 = obj.ExtraDrawPoint;
                pt2 = obj.OuterStartPoint;
                pt3 = obj.OuterEndPoint;
                
                
                if scaledX < actualXScale/2
                    xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
                    x_ = pt2(1) + scaledX*cos(xDirection);
                    y_ = pt2(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.PivotPoint(2) - y_, obj.PivotPoint(1) - x_);
                    scaledY = pdist([[x_ y_];obj.PivotPoint]) - y*pdist([[x_ y_];obj.PivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                else
                    scaledX = scaledX - (actualXScale/2);
                    xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
                    x_ = pt1(1) + scaledX*cos(xDirection);
                    y_ = pt1(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.PivotPoint(2) - y_, obj.PivotPoint(1) - x_);
                    scaledY = pdist([[x_ y_];obj.PivotPoint]) - y*pdist([[x_ y_];obj.PivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                end
            else
                pt1 = obj.ExtraDrawPoint;
                pt2 = obj.InnerStartPoint;
                pt3 = obj.InnerEndPoint;
                
                if scaledX < actualXScale/2
                    xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
                    x_ = pt2(1) + scaledX*cos(xDirection);
                    y_ = pt2(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.PivotPoint(2) - y_, obj.PivotPoint(1) - x_);
                    scaledY = y*pdist([[x_ y_];obj.PivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                else
                    scaledX = scaledX - (actualXScale/2);
                    xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
                    x_ = pt1(1) + scaledX*cos(xDirection);
                    y_ = pt1(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.PivotPoint(2) - y_, obj.PivotPoint(1) - x_);
                    scaledY = y*pdist([[x_ y_];obj.PivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                end
            end
            
            
%             global VirtualHeight;            
%             xDirection = atan2(InnerEndPoint(2)-InnerStartPoint(2), InnerEndPoint(1)-InnerStartPoint(1));
%             xScale = obj.Length / (mapping(2) - mapping(1));
%             x = x - mapping(1);
%             x_ = obj.InnerStartPoint(1) + x*xScale*cos(xDirection);
%             y_ = obj.InnerStartPoint(2) + x*xScale*sin(xDirection);
%             
%             yDirection = atan2(OuterStartPoint(2)-InnerStartPoint(2), OuterStartPoint(1)-InnerStartPoint(1));
%             yScale = obj.Width / VirtualHeight;
%             x_ = x_ + y*yScale*cos(yDirection);
%             y_ = y_ + y*yScale*sin(yDirection);
            
%             x_ = -10;
%             y_ = -10;
        end
                
        function handle = drawPolygon(obj)                        
            handle = fill(obj.Polygon(:,1), obj.Polygon(:,2), 'blue', 'FaceAlpha', 0.1, 'EdgeColor', 'None');
        end
    end
    
end
