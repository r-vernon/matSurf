function surface_load(obj)
% function to load in Freesurfer surface
%
% (set.) TR, triangulation from faces and vertices
% (set.) nVert, total number of vertices
% (set.) G, weighted graph from edges

% =========================================================================
% load in surface and curvature

setStatusTxt('loading surface and calculating centroid');

% surface
try
    [vert, faces] = read_surf(obj.surfDet.surfPath);
catch ME
    fprintf('Could not load requested surface\n(%s)\n',...
        obj.surfDet.curvPath);
    rethrow(ME);
end

% add 1 to faces due to FreeSurfer zero indexing, also swapping cols of
% faces as apparently that fixes normals (according to FreeSurfer script)
faces = faces(:,[1 3 2]) + 1;

% =========================================================================
% calculate additional things from surface and return

%--------------------------------------------------------------------------
% count number of vertices

obj.nVert = single(size(vert,1));
  
%--------------------------------------------------------------------------
% triangulation and centroid

% convert faces and vertices to triangulation TR
% (e.g. nearestNeighbor(TR,P) - find closes vertex to point P)
obj.TR = triangulation(faces,vert);

% set centroid
obj.calcCentroid;

%--------------------------------------------------------------------------
% normals for plotting ROIs

% plot ROI 0.1mm above surface
dist2add = 0;

% calculate vertex normals
vertNorm = vertexNormal(obj.TR);

% calculate set of points ROIs will be plotted over
obj.ROIpts = single(bsxfun(@minus,vert,dist2add*vertNorm));

% append a nan at very end, so can index it to show line finished
obj.ROIpts(obj.nVert+1,:) = nan;

%--------------------------------------------------------------------------
% graph

% use triangulation to created weighted (w) graph G
% (e.g. shortestpath(G,s,t) - find path between vertices s and t)
st = edges(obj.TR);
w = sqrt(sum(bsxfun(@minus,vert(st(:,1),:),vert(st(:,2),:)).^2,2));
obj.G = graph(st(:,1),st(:,2),w);

setStatusTxt('surface loaded');

end