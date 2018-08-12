function calcCentroid(obj,vert)
% function to calculate the centroid of a volume
%
% (req.) vert, set of vertices for volume
% (set.) centroid, centroid of the volume
obj.centroid = [0,0,0]; return;
% make copy of vertices, appending mean point so ensure volume is filled
% (may not be nessary, but shouldn't hurt...)
vert = [vert;mean(vert)];

% split the volume into tetrahedrons (pyramids)
T = delaunay(vert);

% calculate centroids of each tetrahedron
centroids = [...
    mean(reshape(vert(T(:),1),size(T)),2),...
    mean(reshape(vert(T(:),2),size(T)),2),...
    mean(reshape(vert(T(:),3),size(T)),2)...
    ];

% calculate volumes of each tetrahedron
vols = abs(dot(...
    bsxfun(@minus,vert(T(:,1),:),vert(T(:,4),:)),...
    cross(....
    bsxfun(@minus,vert(T(:,2),:),vert(T(:,4),:)),...
    bsxfun(@minus,vert(T(:,3),:),vert(T(:,4),:))...
    ,2),2))/6;

% centroid is volume weighted sum of tetrahedroin centroids
obj.centroid = sum(centroids.*vols)./sum(vols);

end