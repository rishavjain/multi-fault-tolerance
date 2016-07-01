function [ Regions ] = CreateRegion( regionIndex, lowStartPoint, highStartPoint, length, direction, regionType)

Regions(regionIndex).LowStartPoint = lowStartPoint;
Regions(regionIndex).HighStartPoint = highStartPoint;

global Variables;
if isequal(regionType, Variables.REGION_TYPE_STRAIGHT)
    Regions(regionIndex).Width = pdist([lowStartPoint;highStartPoint]);
    Regions(regionIndex).Length = length;    
elseif isequal(regionType, Variables.REGION_TYPE_TURN)
    Regions(regionIndex).Width = length;
    Regions(regionIndex).Length = pdist([lowStartPoint;highStartPoint]);
    
else
    error 'CreateRegion : unknown region type';
end

Regions(regionIndex).Type = regionType;
Regions(regionIndex).Direction = direction;
Regions(regionIndex).Area = Length * Width;
    

end
