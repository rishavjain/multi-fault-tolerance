classdef TurnRegion < Region
    properties
        length
        width
%         PreviousDirection
%         TurnDirection
        pivotPoint
        extraDrawPoint        
    end
    
    methods
        function obj = TurnRegion(inStartPoint, outStartPoint, inEndPoint, outEndPoint)
            obj.inStartPoint = inStartPoint;
            obj.inEndPoint = inEndPoint;
            obj.outStartPoint = outStartPoint;
            obj.outEndPoint = outEndPoint;                                    
            obj.type = Regiontype.TURN;
            obj.length = pdist([inStartPoint;outStartPoint]);
            obj.width = pdist([inEndPoint;outEndPoint]);
            obj.area = obj.length * obj.width;
%             obj.PreviousDirection = PreviousDirection;
%             obj.TurnDirection = TurnDirection;
            
            if isequal(inStartPoint,inEndPoint)
                obj.pivotPoint = inStartPoint;
                angle = atan2(outEndPoint(2)-inEndPoint(2), outEndPoint(1)-outEndPoint(1));
                obj.extraDrawPoint = [outStartPoint(1) + obj.width*cos(angle), outStartPoint(2) + obj.width*sin(angle)];
                obj.Polygon = [obj.inStartPoint; obj.inEndPoint; obj.outEndPoint; obj.extraDrawPoint; obj.outStartPoint; obj.inStartPoint];
            elseif isequal(outStartPoint,outEndPoint)     
                obj.pivotPoint = outStartPoint;
                angle = atan2(inEndPoint(2)-outEndPoint(2), inEndPoint(1)-outEndPoint(1));
                obj.extraDrawPoint = [inStartPoint(1) + obj.width*cos(angle), inStartPoint(2) + obj.width*sin(angle)];
                obj.Polygon = [obj.inStartPoint; obj.extraDrawPoint; obj.inEndPoint; obj.outEndPoint; obj.outStartPoint; obj.inStartPoint];
            end
                                    
            if pdist([inStartPoint;outStartPoint]) ~= pdist([inEndPoint;outEndPoint])
                error 'TurnRegion : unequal width'
            end
        end
        
        function [x_, y_] = mapVirtualPoint(obj, x, y, mapping)
            actualXScale = obj.length + obj.width;
            virtualXScale = mapping(2) - mapping(1);
            
            scaledX = (x - mapping(1)) * actualXScale / virtualXScale;
            
            global VirtualHeight;
            if isequal(obj.pivotPoint, obj.inStartPoint)
                pt1 = obj.extraDrawPoint;
                pt2 = obj.outStartPoint;
                pt3 = obj.outEndPoint;
                
                
                if scaledX < actualXScale/2
                    xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
                    x_ = pt2(1) + scaledX*cos(xDirection);
                    y_ = pt2(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
                    scaledY = pdist([[x_ y_];obj.pivotPoint]) - y*pdist([[x_ y_];obj.pivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                else
                    scaledX = scaledX - (actualXScale/2);
                    xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
                    x_ = pt1(1) + scaledX*cos(xDirection);
                    y_ = pt1(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
                    scaledY = pdist([[x_ y_];obj.pivotPoint]) - y*pdist([[x_ y_];obj.pivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                end
            else
                pt1 = obj.extraDrawPoint;
                pt2 = obj.inStartPoint;
                pt3 = obj.inEndPoint;
                
                if scaledX < actualXScale/2
                    xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
                    x_ = pt2(1) + scaledX*cos(xDirection);
                    y_ = pt2(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
                    scaledY = y*pdist([[x_ y_];obj.pivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                else
                    scaledX = scaledX - (actualXScale/2);
                    xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
                    x_ = pt1(1) + scaledX*cos(xDirection);
                    y_ = pt1(2) + scaledX*sin(xDirection);
                    
                    yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
                    scaledY = y*pdist([[x_ y_];obj.pivotPoint])/VirtualHeight;
                    x_ = x_ + scaledY*cos(yDirection);
                    y_ = y_ + scaledY*sin(yDirection);
                end
            end
            
            
%             global VirtualHeight;            
%             xDirection = atan2(inEndPoint(2)-inStartPoint(2), inEndPoint(1)-inStartPoint(1));
%             xScale = obj.length / (mapping(2) - mapping(1));
%             x = x - mapping(1);
%             x_ = obj.inStartPoint(1) + x*xScale*cos(xDirection);
%             y_ = obj.inStartPoint(2) + x*xScale*sin(xDirection);
%             
%             yDirection = atan2(outStartPoint(2)-inStartPoint(2), outStartPoint(1)-inStartPoint(1));
%             yScale = obj.width / VirtualHeight;
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
