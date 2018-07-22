function surface_load(obj)
% function to load in Freesurfer surface
%
% (set.) TR, triangulation from faces and vertices
% (set.) nVert, total number of vertices
% (set.) xyzLim, necessary axis limits to contain surface
% (set.) obj.cam, sets default/current camera position in cam structure
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
obj.nVert = size(vert,1);

% calculate centroid, then centre volume on it so centroid = origin (0,0,0)
obj.calcCentroid(vert);
vert = bsxfun(@minus,vert,obj.centroid);

%--------------------------------------------------------------------------
% camera details

% set necessary axis limits
obj.xyzLim = ceil(max(abs(vert(:))) * 1.1);

% use that to calculate camera position
%{
% using x - hor. right, z - ver. up, y - depth into screen
% camera target (0,0,0) (centroid), want to 'pull back' on y to show scene
%}
obj.cam.VA_def{1} = [0,-10*obj.xyzLim,0];
obj.VA_cur{1} = obj.cam.VA_def{1}; % current = default at start...

%--------------------------------------------------------------------------
% triangulation

% convert faces and vertices to triangulation TR
% (add 1 to faces due to FreeSurfer zero indexing)
% allows e.g. nearestNeighbor(TR,P) - find closes vertex to point P
obj.TR = triangulation(faces+1,vert);

%--------------------------------------------------------------------------
% graph

% use triangulation to created weighted (w) graph G
% allows e.g. shortestpath(G,s,t) - find path between vertices s and t
st = edges(obj.TR);
w = sqrt(sum(bsxfun(@minus,vert(st(:,1),:),vert(st(:,2),:)).^2,2));
obj.G = graph(st(:,1),st(:,2),w);

setStatusTxt('surface loaded');

end