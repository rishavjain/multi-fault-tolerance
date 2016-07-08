classdef turnregion < region
    properties
%         length
%         width
        pivotPoint
        extraDrawPoint
    end
    
    methods
        function obj = turnregion(s1, s2, e1, e2)
            obj.s1 = s1;
            obj.e1 = e1;
            obj.s2 = s2;
            obj.e2 = e2;
            
            obj.type = 'turn';
            
%             obj.length = pdist([s1;s2]);
%             obj.width = pdist([e1;e2]);
            
            obj.area = pdist([s1;s2]) * pdist([e1;e2]);
            
            if isequal(s1,e1)
                obj.pivotPoint = s1;
                angle = atan2(e2(2)-e1(2), e2(1)-e1(1));
                obj.extraDrawPoint = [s2(1) + pdist([e1;e2])*cos(angle), s2(2) + pdist([e1;e2])*sin(angle)];
                obj.polygon = [obj.s1; obj.e1; obj.e2; obj.extraDrawPoint; obj.s2; obj.s1];
            elseif isequal(s2,e2)
                obj.pivotPoint = s2;
                angle = atan2(e1(2)-e2(2), e1(1)-e2(1));
                obj.extraDrawPoint = [s1(1) + pdist([e1;e2])*cos(angle), s1(2) + pdist([e1;e2])*sin(angle)];
                obj.polygon = [obj.s1; obj.extraDrawPoint; obj.e1; obj.e2; obj.s2; obj.s1];
            end
            
            if abs(pdist([s1;s2]) - pdist([e1;e2])) > 1e-5
                error 'TurnRegion : unequal width'
            end
        end
        
        %         function [x_, y_] = mapVPt(obj, x, y, mapping)
        %             actualXScale = obj.length + obj.width;
        %             virtualXScale = mapping(2) - mapping(1);
        %
        %             scaledX = (x - mapping(1)) * actualXScale / virtualXScale;
        %
        %             if isequal(obj.pivotPoint, obj.s1)
        %                 pt1 = obj.extraDrawPoint;
        %                 pt2 = obj.s2;
        %                 pt3 = obj.e2;
        %
        %
        %                 if scaledX < actualXScale/2
        %                     xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
        %                     x_ = pt2(1) + scaledX*cos(xDirection);
        %                     y_ = pt2(2) + scaledX*sin(xDirection);
        %
        %                     yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
        %                     scaledY = pdist([[x_ y_];obj.pivotPoint]) - y*pdist([[x_ y_];obj.pivotPoint])/obj.length;
        %                     x_ = x_ + scaledY*cos(yDirection);
        %                     y_ = y_ + scaledY*sin(yDirection);
        %                 else
        %                     scaledX = scaledX - (actualXScale/2);
        %                     xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
        %                     x_ = pt1(1) + scaledX*cos(xDirection);
        %                     y_ = pt1(2) + scaledX*sin(xDirection);
        %
        %                     yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
        %                     scaledY = pdist([[x_ y_];obj.pivotPoint]) - y*pdist([[x_ y_];obj.pivotPoint])/obj.width;
        %                     x_ = x_ + scaledY*cos(yDirection);
        %                     y_ = y_ + scaledY*sin(yDirection);
        %                 end
        %             else
        %                 pt1 = obj.extraDrawPoint;
        %                 pt2 = obj.s1;
        %                 pt3 = obj.e1;
        %
        %                 if scaledX < actualXScale/2
        %                     xDirection = atan2(pt1(2) - pt2(2), pt1(1) - pt2(1));
        %                     x_ = pt2(1) + scaledX*cos(xDirection);
        %                     y_ = pt2(2) + scaledX*sin(xDirection);
        %
        %                     yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
        %                     scaledY = y*pdist([[x_ y_];obj.pivotPoint])/obj.length;
        %                     x_ = x_ + scaledY*cos(yDirection);
        %                     y_ = y_ + scaledY*sin(yDirection);
        %                 else
        %                     scaledX = scaledX - (actualXScale/2);
        %                     xDirection = atan2(pt3(2) - pt1(2), pt3(1) - pt1(1));
        %                     x_ = pt1(1) + scaledX*cos(xDirection);
        %                     y_ = pt1(2) + scaledX*sin(xDirection);
        %
        %                     yDirection = atan2(obj.pivotPoint(2) - y_, obj.pivotPoint(1) - x_);
        %                     scaledY = y*pdist([[x_ y_];obj.pivotPoint])/obj.width;
        %                     x_ = x_ + scaledY*cos(yDirection);
        %                     y_ = y_ + scaledY*sin(yDirection);
        %                 end
        %             end
        %
        %
        %             %             global VirtualHeight;
        %             %             xDirection = atan2(inEndPoint(2)-inStartPoint(2), inEndPoint(1)-inStartPoint(1));
        %             %             xScale = obj.length / (mapping(2) - mapping(1));
        %             %             x = x - mapping(1);
        %             %             x_ = obj.s1(1) + x*xScale*cos(xDirection);
        %             %             y_ = obj.s1(2) + x*xScale*sin(xDirection);
        %             %
        %             %             yDirection = atan2(outStartPoint(2)-inStartPoint(2), outStartPoint(1)-inStartPoint(1));
        %             %             yScale = obj.width / VirtualHeight;
        %             %             x_ = x_ + y*yScale*cos(yDirection);
        %             %             y_ = y_ + y*yScale*sin(yDirection);
        %
        %             %             x_ = -10;
        %             %             y_ = -10;
        %         end
        
        function [x_, y_] = mapVPt(obj, x, y, mapping)
            actualXScale = pdist([obj.s1; obj.s2]) + pdist([obj.e1; obj.e2]);
            virtualXScale = mapping(2) - mapping(1);
            
            Xs = (x - mapping(1)) * actualXScale / virtualXScale;
            
            if isequal(obj.pivotPoint, obj.s1)
                s1 = obj.s1;
                s2 = obj.s2;
                e2 = obj.e2;
            elseif isequal(obj.pivotPoint, obj.s2)
                s1 = obj.s2;
                s2 = obj.s1;
                e2 = obj.e1;
            else
                error 'pivot pt does not match any starting point'
            end
            
            D = obj.extraDrawPoint;
            
            l1 = vec_diff(D, s2);
            l2 = vec_diff(e2, D);
            
            if Xs <= l1
                [~, xdir] = vec_diff(D, s2);
                x_ = s2(1) + Xs*cos(xdir);
                y_ = s2(2) + Xs*sin(xdir);                               
            else
                [~, xdir] = vec_diff(e2, D);
                x_ = D(1) + (Xs - l1)*cos(xdir);
                y_ = D(2) + (Xs - l1)*sin(xdir);
            end
            
            [ylen, ydir] = vec_diff([x_ y_], s1);
            Ys = y * ylen / pdist([obj.s1; obj.s2]);
            
            if isequal(obj.pivotPoint, obj.s1)
                x_ = s1(1) + Ys*cos(ydir);
                y_ = s1(2) + Ys*sin(ydir);
            elseif isequal(obj.pivotPoint, obj.s2)
                x_ = x_ + Ys*cos(ydir + pi);
                y_ = y_ + Ys*sin(ydir + pi);
            end            
        end
        
        function [x, y] = revMapVPt(obj, x_, y_, mapping)
            x = 0;
            y = 0;
        end
        
        function handle = draw_polygon(obj, color, alpha, edge)
            if ~exist('color', 'var')
                color = 'w';
            end
            
            if ~exist('alpha', 'var')
                alpha = 0.2;
            end
            
            if ~exist('edge', 'var')
                edge = 'None';
            end
            
            handle = fill(obj.polygon(:,1), obj.polygon(:,2), color, 'FaceAlpha', alpha, 'EdgeColor', edge);
            
            if isequal(obj.s1,obj.pivotPoint)
                plot(obj.polygon(3:4,1), obj.polygon(3:4,2), 'k');
                plot(obj.polygon(4:5,1), obj.polygon(4:5,2), 'k');
            elseif isequal(obj.s2,obj.pivotPoint)
                plot(obj.polygon(1:2,1), obj.polygon(1:2,2), 'k');
                plot(obj.polygon(2:3,1), obj.polygon(2:3,2), 'k');
                
            end
        end
    end
    
end

function [len, dir] = vec_diff(vec1, vec2)
% returns length and direction of (vec1 - vec2)
    len = sqrt((vec1 - vec2)*(vec1 - vec2)');
    dir = atan2(vec1(2) - vec2(2), vec1(1) - vec2(1));
end
