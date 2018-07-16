function surface_load(obj)
% function to load in Freesurfer surface
%
% (set.) TR, triangulation from faces and vertices
% (set.) nVert, total number of vertices
% (set.) xyzLim, necessary axis limits to contain surface
% (set.) G, weighted graph from edges

% =========================================================================
% load in surface and curvature

%{
note in freesurfer_readsurf it suggests swapping cols of faces when reading
into matlab (i.e. faces = faces(:,[1 3 2])) to fix normals, however as
we're using triangulation that doesn't seem to be true, so not doing it.
Can double check if necessary with 'verifyNormals' script
%}

setStatusTxt('loading surface and calculating centroid');

% surface
try
    [vert, faces] = read_surf(obj.surfDet.surfPath);
catch ME
    fprintf('Could not load requested surface\n(%s)\n',...
        obj.surfDet.curvPath);
    rethrow(ME);
end

% =========================================================================
% calculate additional things from surface and return

% count number of vertices
obj.nVert = single(size(vert,1));

% calculate centroid, then centre volume on it so centroid = origin (0,0,0)
obj.calcCentroid(vert);
vert = bsxfun(@minus,vert,obj.centroid);

% set necessary axis limits
obj.xyzLim = ceil(max(abs(vert(:)))) + 1;

%--------------------------------------------------------------------------
% triangulation

% convert faces and vertices to triangulation TR
% (add 1 to faces due to FreeSurfer zero indexing)
% allows e.g. nearestNeighbor(TR,P) - find closes vertex to point P
obj.TR = triangulation(faces+1,vert);

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
% allows e.g. shortestpath(G,s,t) - find path between vertices s and t
st = edges(obj.TR);
w = sqrt(sum(bsxfun(@minus,vert(st(:,1),:),vert(st(:,2),:)).^2,2));
obj.G = graph(st(:,1),st(:,2),w);

setStatusTxt('surface loaded');

end