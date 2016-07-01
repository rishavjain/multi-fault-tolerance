function pol = GET_POLYGON(x_limit)

global partitionH
pol = [x_limit(1) 0 ;x_limit(2) 0 ;x_limit(2) partitionH ;x_limit(1) partitionH ;x_limit(1) 0];

% if H~=-1
%     set(H, 'XData', pol(:,1), 'YData', pol(:,2));
% end

end