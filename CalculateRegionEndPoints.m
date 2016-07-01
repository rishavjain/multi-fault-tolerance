function [ LowEndPoint, HighEndPoint ] = CalculateRegionEndPoints( LowStartPoint, HighStartPoint, Direction, Length )

LowEndPoint = LowStartPoint + Length * cosd(Direction);
HighEndPoint = HighStartPoint + Length * cosd(Direction);

end
