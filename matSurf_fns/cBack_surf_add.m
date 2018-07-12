function cBack_surf_add(src)

% get data
f_h = getFigHandle(src);
allVol = getappdata(f_h,'allVol');
cmaps = getappdata(f_h,'cmaps');
handles = getappdata(f_h,'handles');

% set all axis limits to auto
handles.brainAx.XLimMode = 'auto';
handles.brainAx.YLimMode = 'auto';
handles.brainAx.ZLimMode = 'auto';

% add a new volume and copy out as 'current'
currVol = allVol.addVol(brainSurf(cmaps));

% initialise session details (TODO - get user input)
SUBJECTS_DIR = [pwd,'/Data'];
subject = 'R3517';
hemi = 'rh';
surfType = 'inflated';

% set surfName, plus surf and curv to load
surfName = strcat(subject,'_',hemi);
fPath = fullfile(SUBJECTS_DIR,subject,'surf',{[hemi,'.',surfType],[hemi,'.curv']});
currVol.surface_setDetails(fPath{1},fPath{2},surfName)

% initialise a surface
% contains triangulation (TR), graph (G) and numVertices (nVert)
currVol.surface_load;

% load the base overlay (curvature information), using default colours
currVol.ovrlay_base;

% make sure all cameras are off and set camera target to centroid
handles.rotCam.Value  = 0;
handles.panCam.Value  = 0;
handles.zoomCam.Value = 0;
handles.brainAx.CameraTarget = currVol.centroid;

% display it
set(handles.brainPatch,...
    'vertices',single(currVol.TR.Points),...
    'faces',single(currVol.TR.ConnectivityList),...
    'FaceVertexCData',currVol.currOvrlay.colData,...
    'VertexNormals',single(vertexNormal(currVol.TR)),...
    'FaceNormals',single(faceNormal(currVol.TR)),...
    'visible','on');
view(handles.brainAx,90,0) % set view to Y-Z
drawnow;

% add it to pop up menu
handles.selSurf.String = allVol.vNames;
handles.selSurf.Value =  allVol.cVol;

% set the limits back to manual so doesn't have to recompute
handles.brainAx.XLimMode = 'manual';
handles.brainAx.YLimMode = 'manual';
handles.brainAx.ZLimMode = 'manual';

% save out updated data
setappdata(f_h,'currVol',currVol); 

end
