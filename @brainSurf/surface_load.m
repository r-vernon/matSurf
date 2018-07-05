function surface_load(obj)
% function to load in Freesurfer surface
%
% (set.) TR, triangulation from faces and vertices
% (set.) nVert, total number of vertices
% (set.) G, weighted graph from edges

% =========================================================================
% load in surface and curvature

% grab surface details
surfDet = obj.surfDet;

% surface 
fName = strcat(surfDet.SUBJECTS_DIR,'/surf/',surfDet.hemi,'.',surfDet.surfType);
[vert, faces] = read_surf(fName);

% add 1 to faces due to FreeSurfer zero indexing, also swapping cols of
% faces as apparently that fixes normals (according to FreeSurfer script)
faces = faces(:,[1 3 2]) + 1;

% =========================================================================
% calculate additional things from surface and return

%--------------------------------------------------------------------------
% count number of vertices

obj.nVert = uint32(size(vert,1));

%--------------------------------------------------------------------------
% triangulation

% convert faces and vertices to triangulation TR
% (e.g. nearestNeighbor(TR,P) - find closes vertex to point P)
obj.TR = triangulation(faces,vert);

%--------------------------------------------------------------------------
% normals for plotting ROIs

% plot ROI 0.1mm above surface
dist2add = 0.1;

% calculate vertex normals
vertNorm = vertexNormal(obj.TR);

% calculate set of points ROIs will be plotted over
obj.ROIpts = single(bsxfun(@plus,vert,dist2add*vertNorm));

%--------------------------------------------------------------------------
% graph

% use triangulation to created weighted (w) graph G
% (e.g. shortestpath(G,s,t) - find path between vertices s and t)
st = edges(obj.TR);
w = sqrt(sum(bsxfun(@minus,vert(st(:,1),:),vert(st(:,2),:)).^2,2));
obj.G = graph(st(:,1),st(:,2),w);

end