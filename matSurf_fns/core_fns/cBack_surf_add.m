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
surfName = strcat(subject,'_',hemi,'_',surfType(1:2));
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
    'vertices',currVol.TR.Points,...
    'faces',currVol.TR.ConnectivityList,...
    'FaceVertexCData',currVol.currOvrlay.colData,...
    'VertexNormals',vertexNormal(currVol.TR),...
    'FaceNormals',faceNormal(currVol.TR),...
    'visible','on');

% set lights on
lPos = handles.brainAx.XLim(2);
lPos = [lPos/2,-2*lPos,lPos/2];
handles.llLight.Position = [-lPos(1), lPos(2), -lPos(3)];
handles.ulLight.Position = [-lPos(1), lPos(2),  lPos(3)];
handles.lrLight.Position = [ lPos(1), lPos(2), -lPos(3)];
handles.urLight.Position = [ lPos(1), lPos(2),  lPos(3)];

% reset vertex edit entry
handles.svEdit.String = '';

% enable data/ROI interactions, plus reset them
set(handles.dataPanel.Children,'Enable','on');
set(handles.selData,'String','Select Data','Value',1);
handles.togData.Value = 1;
set(handles.roiPanel.Children,'Enable','on');
set(handles.selROI,'String','Select ROI','Value',1);
handles.togROI.Value = 1;
set(handles.brainROI,'XData',[],'YData',[],'ZData',[]);

% set default view and initialise callbacks
handles.matSurfFig.WindowScrollWheelFcn = @cam_scrollWhFn;
handles.axisPanel.ButtonDownFcn  = @cam_bDownFcn;
handles.brainPatch.ButtonDownFcn = @cam_bDownFcn;

% add it to pop up menu and update title
handles.selSurf.String = allVol.vNames;
handles.selSurf.Value =  allVol.cVol;
handles.matSurfFig.Name = ['matSurf - ',surfName];

% save out updated data
setappdata(f_h,'currVol',currVol); 
setappdata(f_h,'camCont',camCont); 

drawnow;

end
