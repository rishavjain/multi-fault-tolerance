function [pos, theta] = GET_NEXT_POSITION(Mode, c_pos, c_theta, boundary, headingPt)

global Step_Size

if Mode == 1
    if isempty(headingPt)
        new_theta = c_theta + 0.4*(pi*rand - pi/2); 
        new_pos = [c_pos(1)+Step_Size*cos(new_theta) c_pos(2)+Step_Size*sin(new_theta)];    

        if(inpolygon(new_pos(1), new_pos(2), boundary(:,1), boundary(:,2))==0)
%             new_theta = c_theta + 2.4*(pi*rand - pi/2);
%             new_pos = [c_pos(1)+Step_Size*cos(new_theta) c_pos(2)+Step_Size*sin(new_theta)];
            [new_pos, new_theta] = GET_NEXT_POSITION(1, c_pos, c_theta, boundary, mean(boundary(1:end-1,:)));
        end
    else
        new_theta = atan2(headingPt(2) - c_pos(2), headingPt(1) - c_pos(1));

        new_pos = [c_pos(1)+Step_Size*cos(new_theta) c_pos(2)+Step_Size*sin(new_theta)];    
        step = Step_Size;
        
        if inpolygon(c_pos(1), c_pos(2), boundary(:,1), boundary(:,2))==1
            while(inpolygon(new_pos(1), new_pos(2), boundary(:,1), boundary(:,2))==0)
        %         new_theta = c_theta + 2.4*(pi*rand - pi/2);
                step = step/2;
                new_pos = [c_pos(1)+step*cos(new_theta) c_pos(2)+step*sin(new_theta)];        
            end
        end
    end
end

if Mode == 2
    new_theta = c_theta;
    new_pos = [c_pos(1)+Step_Size*cos(c_theta) c_pos(2)];
    
    if(inpolygon(new_pos(1), new_pos(2), boundary(:,1), boundary(:,2))==0)
        m = mean(boundary(1:end-1,:));
        
        new_theta = (m(1)<c_pos(1))*pi + (m(1)>c_pos(1))*0;
        new_pos = [c_pos(1)+Step_Size*cos(new_theta) c_pos(2)];        
    end
end

pos = new_pos;
theta = new_theta;
    
end