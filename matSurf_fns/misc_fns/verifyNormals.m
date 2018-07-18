function verifyNormals(TR)
% function to verify that vertex and face normals face right way
%
% (req.) TR, triangulation to get normals from

% grab the data to check
V = vertexNormal(TR); % vertex normals
P = incenter(TR);     % center of each face
F = faceNormal(TR);   % face normals

% reduce number of vertices/faces to plot
nV = uint32(linspace(1,length(V),1e4/2));
nF = uint32(linspace(1,length(F),1e4/2));

% open up a new figure and show camera toolbar
figure;
cameratoolbar;

% create a patch opject, white face, no vertices shown
patch('faces',TR.ConnectivityList,'vertices',TR.Points,...
    'FaceColor',[0.8,0.8,0.8],'EdgeColor','none','FaceAlpha',0.6);

% grab the axis and lock its aspect ratio, plus set hold on
ax = gca;
set(ax,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual',...
    'PlotBoxAspectRatio',[1,1,1],'PlotBoxAspectRatioMode','manual');
hold(ax,'on');

% plot the Vertex normals
quiver3(TR.Points(nV,1),TR.Points(nV,2),TR.Points(nV,3), ...
    V(nV,1),V(nV,2),V(nV,3),0.5,'Color','b');

% plot the Face normals
quiver3(P(nF,1),P(nF,2),P(nF,3),F(nF,1),F(nF,2),F(nF,3),0.5,'color','r');

% add legend
legend('Surface','Vertex Normals','Face Normals');

end