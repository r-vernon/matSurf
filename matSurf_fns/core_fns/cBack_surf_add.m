function cBack_surf_add(src,~)

% get data
f_h        = getFigHandle(src);
allVol     = getappdata(f_h,'allVol');
cmaps      = getappdata(f_h,'cmaps');
handles    = getappdata(f_h,'handles');

% see if subjects_dir is available
SUBJECTS_DIR = '';
if isappdata(f_h,'SUBJECTS_DIR')
    SUBJECTS_DIR = getappdata(f_h,'SUBJECTS_DIR');
end

% get session details
[surfDet,success] = UI_findSurf(SUBJECTS_DIR);
drawnow; pause(0.05);

% if success is false (e.g. clicked cancel), do nothing
if ~success, return; end

% must have req. details, so add a new volume and copy out as 'current'
currVol = allVol.addVol(brainSurf(cmaps));
setappdata(f_h,'currVol',currVol);

% pass surface details through to the volume 
currVol.surface_setDetails(surfDet);

% update SUBJECTS_DIR
setappdata(f_h,'SUBJECTS_DIR',surfDet.SUBJECTS_DIR);

%--------------------------------------------------------------------------

% initialise a surface
% contains triangulation (TR), graph (G) and numVertices (nVert)
currVol.surface_load;

% load the base overlay (curvature information), using default colours
currVol.ovrlay_base;

%--------------------------------------------------------------------------

% update status (sa = surface added)
mS_stateControl(f_h,'sa');

% add it to pop up menu and update title
handles.selSurf.String = allVol.vNames;
handles.selSurf.Value =  allVol.cVol;

drawnow; pause(0.05);

end
