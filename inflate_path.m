function env = inflate_path( params, path, inflationSize )

logger(params, 1, sprintf('inflating path ...'));

for iPt = 1:size(path,2)-1
    logger(params, 1, sprintf('idx: %d', iPt));
    
    pt1 = path(:,iPt)';
    pt2 = path(:,iPt + 1)';
    
    logger(params, 1, sprintf('pt1: [%3d %3d], pt2:[%3d %3d]', pt1, pt2));
    
    slope = (pt2(2) - pt1(2)) / (pt2(1) - pt1(1));
    logger(params, 1, sprintf('slope: %d', slope));
    
    length = pdist([pt1; pt2], 'euclidean');
    logger(params, 1, sprintf('length: %d', length));
    
    if length >= 2*inflationSize
%         inStartPt = 
    else
        logger(params, 5, sprintf('ERROR: inflate_path.m: length of line segment should be greater than 2*inflationSize'));
    end
end


end
