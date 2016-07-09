function [fig1handle] = resetfigure(params)

close all

fig1Number = params.fig1.num;

fig1handle = figure(fig1Number);

set(fig1Number, 'Name', 'Area Coverage', 'NumberTitle', 'off');
clf;

%%% maximizing the window
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFrame = get(fig1Number,'JavaFrame');
pause(0.0001);
set(jFrame,'Maximized',1);
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

set(gcf,'color','w');
% subplot(1,2,2);
% cla
% hold all;
% 
% axis equal;
% % axis off;
% 
% grid on;
% grid minor;

% set(gcf, 'CloseRequestFcn', @VirtualEnvironmentCloseCallback)

end
