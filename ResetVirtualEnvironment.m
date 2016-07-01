function ResetVirtualEnvironment()
%RESETVIRTUALMAP Summary of this function goes here
%   Detailed explanation goes here

figureHandle = 1;
figure(figureHandle);
set(figureHandle, 'Name', 'Virtual Map', 'NumberTitle', 'off');
clf;

%%% maximizing the window
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jFrame = get(figureHandle,'JavaFrame');
pause(0.0001);
set(jFrame,'Maximized',1);
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

set(gcf,'color','w');

subplot(1,2,1);
hold all;

axis equal;
axis off;

% set(gcf, 'CloseRequestFcn', @VirtualEnvironmentCloseCallback)

end
