function ResetActualEnvironment()
%RESETVIRTUALMAP Summary of this function goes here
%   Detailed explanation goes here

% figureHandle = 2;
% figure(figureHandle);
% set(figureHandle, 'Name', 'Actual Map', 'NumberTitle', 'off');
% clf;
% 
% %%% maximizing the window
% warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% jFrame = get(figureHandle,'JavaFrame');
% pause(0.0001);
% set(jFrame,'Maximized',1);
% warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% 
% set(gcf,'color','w');
subplot(1,2,2);
cla
hold all;

axis equal;
axis off;

% set(gcf, 'CloseRequestFcn', @VirtualEnvironmentCloseCallback)

end
