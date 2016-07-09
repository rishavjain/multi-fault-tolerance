function [ mappedPt ] = map_virtual_pt( pt, regions, mapping )

regionIdx = find(mapping(:,1) <= pt(1), 1, 'last');

[mappedX, mappedY] = regions(regionIdx).mapVPt(pt(1), pt(2), mapping(regionIdx,:));

mappedPt = [mappedX, mappedY];

end
