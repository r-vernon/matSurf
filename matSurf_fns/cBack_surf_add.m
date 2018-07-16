function cBack_surf_add(src,~)

% get data
f_h = getFigHandle(src);
allVol = getappdata(f_h,'allVol');
cmaps = getappdata(f_h,'cmaps');
camCont = getappdata(f_h,'camCont');
handles = getappdata(f_h,'handles');

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

%--------------------------------------------------------------------------

% initialise a surface
% contains triangulation (TR), graph (G) and numVertices (nVert)
currVol.surface_load;

% load the base overlay (curvature information), using default colours
currVol.ovrlay_base;

%--------------------------------------------------------------------------

% set xyz limits for axis
xyzLim = [-1,1] * currVol.xyzLim;
set(handles.brainAx,'XLim',xyzLim,'YLim',xyzLim,'ZLim',xyzLim);

% set the camera position to default
set(handles.brainAx,currVol.cam.NA,currVol.cam.VA_def);
handles.xForm.Matrix = qRotMat(currVol.cam.q_def);

% make sure camCont is in 'reset' state
camCont.mMoved = false;
camCont.clPatch = false;
camCont.qForm = currVol.cam.q_def;

% display it
set(handles.brainPatch,...
    'vertices',single(currVol.TR.Points),...
    'faces',single(currVol.TR.ConnectivityList),...
    'FaceVertexCData',currVol.currOvrlay.colData,...
    'VertexNormals',single(vertexNormal(currVol.TR)),...
    'FaceNormals',single(faceNormal(currVol.TR)),...
    'visible','on');

% set lights on
light_d2m = atand(30) * abs(handles.brainAx.CameraPosition(2));
handles.llLight.Position = [-light_d2m, -2.5*currVol.xyzLim, -light_d2m];
handles.lrLight.Position = [ light_d2m, -2.5*currVol.xyzLim, -light_d2m];
handles.ulLight.Position = [-light_d2m, -2.5*currVol.xyzLim,  light_d2m];
handles.urLight.Position = [ light_d2m, -2.5*currVol.xyzLim,  light_d2m];
handles.aLights.Visible = 'on';

% draw it
drawnow;

% set default view and initialise callbacks
handles.brainAx.ButtonDownFcn    = @cam_bDownFcn;
handles.brainPatch.ButtonDownFcn = @cam_bDownFcn;

% add it to pop up menu
handles.selSurf.String = allVol.vNames;
handles.selSurf.Value =  allVol.cVol;

% save out updated data
setappdata(f_h,'currVol',currVol); 
setappdata(f_h,'camCont',camCont); 

end
