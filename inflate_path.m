function env = inflate_path( params )

path = params.env.path;
inflationSize = params.env.inflationSize;

logger(params, 2, sprintf('inflating path'));

% check if path contains atleast more than
if size(path,2)<3
    logger(params, 3, sprintf('path should contain atleast 3 points'));
    error 'path should contain atleast 3 points';
end

% calculate the starting points for the env
pt1 = path(:,1)';
pt2 = path(:,2)';   logger(params, 1, sprintf('pt1: [%3d %3d], pt2:[%3d %3d]', pt1, pt2));

theta1 = atan2((pt2(2) - pt1(2)),(pt2(1) - pt1(1))); logger(params, 1, sprintf('pt1: [%3d %3d], pt2:[%3d %3d]', pt1, pt2));

e1 = [pt1(1) + inflationSize*sqrt(2)*cos(theta1 - (3*pi/4)), pt1(2) + inflationSize*sqrt(2)*sin(theta1 - (3*pi/4))];
e2 = [pt1(1) + inflationSize*sqrt(2)*cos(theta1 + (3*pi/4)), pt1(2) + inflationSize*sqrt(2)*sin(theta1 + (3*pi/4))];

regionLengthCompensate = 0;

env = [];
for iPt = 1:size(path,2)-2
    
%     if iPt == 7
%         dbstack;
%     end
    
    logger(params, 1, sprintf('idx: %d', iPt));
    
    pt1 = path(:,iPt)';
    pt2 = path(:,iPt + 1)';
    logger(params, 1, sprintf('pt1: [%3d %3d], pt2:[%3d %3d]', pt1, pt2));
    
    theta1 = atan2((pt2(2) - pt1(2)),(pt2(1) - pt1(1)));
    logger(params, 1, sprintf('theta: %d', theta1));
    
    if ~check_theta(theta1)
        logger(params, 3, sprintf('only horizontal and vertical lines in path supported'));
        error 'only horizontal and vertical lines in path supported';
    end
    
    length1 = pdist([pt1; pt2], 'euclidean');
    logger(params, 1, sprintf('length: %d', length1));
    
    if length1 < 2*inflationSize
        logger(params, 3, sprintf('length of line segment should be greater than 2*inflationSize'));
        error 'length of line segment should be greater than 2*inflationSize';
    end
    
    s1 = e1;
    s2 = e2;
    e1 = [s1(1) + (length1-regionLengthCompensate)*cos(theta1), s1(2) + (length1-regionLengthCompensate)*sin(theta1)];
    e2 = [s2(1) + (length1-regionLengthCompensate)*cos(theta1), s2(2) + (length1-regionLengthCompensate)*sin(theta1)];
    
%     plot(s1(1), s1(2), 'b.');
%     plot(s2(1), s2(2), 'bo');
%     plot(e1(1), e1(2), 'b*');
%     plot(e2(1), e2(2), 'bx');
    
    region1 = straightregion(s1, s2, e1, e2);
%     region1.draw_polygon();
    
    pt3 = path(:,iPt+2)';
    theta2 = atan2((pt3(2) - pt2(2)),(pt3(1) - pt2(1)));
    
    if ~check_theta(theta2)
        logger(params, 3, sprintf('only horizontal and vertical lines in path supported'));
        error 'only horizontal and vertical lines in path supported';
    end
    
    s1 = e1;
    s2 = e2;
    
    diagTheta = atan2(pt3(2)-pt1(2), pt3(1)-pt1(1));
    diagLength = pdist([pt3; pt1], 'euclidean');
    
    %     fill([pt1(1), pt3(1), pt3(1), pt1(1), pt1(1)], [pt1(2), pt1(2), pt3(2), pt3(2), pt1(2)], 'g', 'FaceAlpha', 0.1);
    
    if InPolygon(s1(1), s1(2), [pt1(1), pt3(1), pt3(1), pt1(1), pt1(1)], [pt1(2), pt1(2), pt3(2), pt3(2), pt1(2)])
        e1 = s1;
        e2 = [e1(1) + 2*inflationSize*cos(theta2+(pi/2)),  e1(2) + 2*inflationSize*sin(theta2+(pi/2))];
    else
        e2 = s2;
        e1 = [e2(1) + 2*inflationSize*cos(theta2-(pi/2)),  e2(2) + 2*inflationSize*sin(theta2-(pi/2))];
    end
    
%     plot(s1(1), s1(2), 'r.');
%     plot(s2(1), s2(2), 'ro');
%     plot(e1(1), e1(2), 'r*');
%     plot(e2(1), e2(2), 'rx');
    
    region2 = turnregion(s1, s2, e1, e2);
%     region2.draw_polygon();

    env = [env; region1; region2];
    
    regionLengthCompensate = 2*inflationSize;        
end

s1 = e1;
s2 = e2;

length1 = pdist([pt3; pt2], 'euclidean');

e1 = [s1(1) + length1*cos(theta2), s1(2) + length1*sin(theta2)];
e2 = [s2(1) + length1*cos(theta2), s2(2) + length1*sin(theta2)];

region1 = straightregion(s1, s2, e1, e2);
% region1.draw_polygon();

env = [env; region1];

for iRegion = 1:length(env)
    for jRegion = iRegion+1:length(env)
        [~, ~, in] = InPolygon(env(iRegion).polygon(:,1), env(iRegion).polygon(:,2), env(jRegion).polygon(:,1), env(jRegion).polygon(:,2));
        
        if ~isempty(find(in == 1, 1))
            error 'inflated area overlaps (check the path)';
        end
    end
end

end

function [result] = check_theta(slope)
slope = abs(slope);

if abs(slope - pi) < 1e-5
    result = 1;
elseif abs(slope - pi/2) < 1e-5
    result = 1;
elseif abs(slope - 0) < 1e-5
    result = 1;
else
    result = 0;
end
end
