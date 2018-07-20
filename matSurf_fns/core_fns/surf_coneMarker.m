function surf_coneMarker(f_h,ip)
% function to create and display cone marker on selected vertex
%
% (req.) f_h, handle to figure
% (req.) pt,  point clicked on surface (i.e. vertex coords)
% (req.) vn,  vertex normal for pt

% get data
handles = getappdata(f_h,'handles');
markSize = getappdata(f_h,'markSize');

% set number of cone points around top, cone length and cone radius
coneN = 25;
coneL = markSize(1);
coneR = markSize(2);

% create angles about circle
th = linspace(0,2*pi,coneN+1)';
th(end) = [];

%--------------------------------------------------------------------------
% grab required coords from brainPatch

% point (pt) clicked
pt = handles.brainPatch.Vertices(ip,:);

% vertex normals (vn) at that point
vn = handles.brainPatch.VertexNormals(ip,:);

%--------------------------------------------------------------------------
% find plane orthogonal to vertex normal

% calculate two orth. vectors to vector normal (vn)
% when orth., a.b = 0, let a = [xyz], b = [11c] (c unknown)
% a.b = (x+y+cz)/3 = 0, cz = -x-y, c = -(x+y)/z
vnO1 = [1, 1, -(vn(1)+vn(2))/vn(3)];
vnO1 = coneR * vnO1/norm(vnO1);

% use same principle to find Orth2, setting up simultaneous eqs (2 unknowns)
% (could also use cross-product but inline faster)
vnO2 = [1,NaN,((vnO1(2)*vn(1))-(vn(2)*vnO1(1)))/((vn(2)*vnO1(3))-(vnO1(2)*vn(3)))];
vnO2(2) = -(vn(1)+(vnO2(3)*vn(3)))/vn(2);
vnO2 = coneR * vnO2/norm(vnO2);

%--------------------------------------------------------------------------
% create cone

% calculate circular centre, storing as cone vertices
cCent = pt + coneL*vn; % circle centre

% calculate vertices and faces, sending both immediatialy for triangulation
% faces: 1st 'col' (ones(...) bit down) maps cone point to circ coords
% faces: 2nd 'col' (repmat(...) bit down) maps cCent to circ coords
% vertices: vert clicked will be first pnt, then circ. coords, then circ centre)
coneTR = triangulation([...
    ones(1,coneN),        repmat((coneN +2),1,coneN);... % vert1 in faces
    2:(coneN +1),         (coneN +1), 2:coneN;...        % vert2 in faces
    (coneN +1), 2:coneN,  2:(coneN +1)]',...             % vert3 in faces
    ...
    [pt; cCent + cos(th)*vnO1 + sin(th)*vnO2; cCent]...  % corresp. vertices
    );

%--------------------------------------------------------------------------
% display it

% set face color
coneC = [repmat([0,1,0],coneN,1); repmat([0,0.6,0],coneN,1)];

set(handles.markPatch,...
    'vertices',coneTR.Points,...
    'faces',coneTR.ConnectivityList,...
    'VertexNormals',vertexNormal(coneTR),...
    'FaceNormals',faceNormal(coneTR),...
    'FaceVertexCData',coneC);

end