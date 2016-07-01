function VirtualMapCloseCallback(~, ~)

delete(gcf);
error('Virtual Map Window Closed');

end