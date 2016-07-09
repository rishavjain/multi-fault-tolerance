function [ mappedPt ] = revmap_virtual_pt( pt, regions, mapping )

regionIdx = find(mapping(:,1) <= pt(1), 1, 'last');

[revmappedX, revmappedY] = regions(regionIdx).revMapVPt(pt(1), pt(2), mapping(regionIdx,:));

mappedPt = [revmappedX, revmappedY];

end
