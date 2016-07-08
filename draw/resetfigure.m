function resetfigure(params)

figNumber = params.fig.num;

close all

figure(figNumber);
set(figNumber, 'Name', 'Area Coverage', 'NumberTitle', 'off');
clf;

%%% maximizing the window
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFrame = get(figNumber,'JavaFrame');
pause(0.0001);
set(jFrame,'Maximized',1);
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

set(gcf,'color','w');
% subplot(1,2,2);
% cla
hold all;

axis equal;
% axis off;

grid on;
grid minor;

% set(gcf, 'CloseRequestFcn', @VirtualEnvironmentCloseCallback)

end
