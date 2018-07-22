function cBack_surf_add(src,~)

% get data
f_h        = getFigHandle(src);
allVol     = getappdata(f_h,'allVol');
cmaps      = getappdata(f_h,'cmaps');
handles    = getappdata(f_h,'handles');

% add a new volume and copy out as 'current'
currVol = allVol.addVol(brainSurf(cmaps));
setappdata(f_h,'currVol',currVol);

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

% update status (sa = surface added)
mS_stateControl(f_h,'sa');

% add it to pop up menu and update title
handles.selSurf.String = allVol.vNames;
handles.selSurf.Value =  allVol.cVol;

drawnow;

end
