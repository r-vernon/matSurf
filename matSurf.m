function [f_h] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================

% set all paths and make sure freesurfer is available
[baseDir,~,~] = fileparts(mfilename('fullpath'));
matSurf_pathSetup(baseDir);

% create the figure and associated handles
[f_h,handles] = mS_create_fig(0);

% initialise the colormaps
setappdata(f_h,'cmaps',cmaps);

% initialise a volStore class, this will store handles to all surface vols
% loaded, so can swap between them
setappdata(f_h,'allVol',mS_volStore);

% create camera control structure
%{
view    - if a saved view is loaded, this stores name (wiped upon rotation)
mSens   - mouse sensitivity for (order): rotation, panning, zooming
mMoved  - true if mouse moved
mPos1   - mouse position at click (wrt. axis (normal Cl.) or fig (extend Cl.)
mState  - normal (LClick), extend (L+R Click, ScrWh Click), alt (RClick)
clPatch - true if click came from patch
ip      - intersection point between click/patch if clicked patch
qForm   - rotation matrix in quaternion form
tStmp   - time stamp of button down
fRate   - frame rate limit of camera
%}
camControl = struct(...
    'view','','mSens',[1.5,1.5,1.5],'mState','','mPos1',[],'mMoved',false,...
    'clPatch',false,'ip',[],'qForm',[],'tStmp',clock,'fRate',1/60);
setappdata(f_h,'camControl',camControl);

% set marker size preferences (length, radius)
setappdata(f_h,'markSize',[5,1]);

% set SUBJECTS_DIR
setappdata(f_h,'SUBJECTS_DIR',[pwd,'/Data']);

% show the figure
f_h.Visible = 'on';

% make sure everything is fully drawn (adding pause due to: 
% http://undocumentedmatlab.com/blog/solving-a-matlab-hang-problem)
drawnow; pause(0.05);

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback  = @cBack_surf_add;

% select surface
handles.selSurf.Callback  = @cBack_surf_select;

% select vertex
handles.svEdit.Callback   = @cBack_surf_setVert;

% reset camera (in this panel just for convenience)
handles.resCam.Callback   = @cBack_cam_camReset;

% save surface
handles.saveSurf.Callback = @cBack_surf_save;

% =========================================================================
% data button callbacks

% load data
handles.addData.Callback = @cBack_data_add;

% select data
handles.selData.Callback = @cBack_data_select;

% delete data
handles.delData.Callback = @cBack_data_delete;

% display data toggle
handles.togData.Callback = @cBack_data_toggle;

% =========================================================================
% ROI button callbacks

% add ROI
handles.addROI.Callback = @cBack_mode_set;

% delete ROI
handles.delROI.Callback = @cBack_ROI_delete;

% save ROI
handles.saveROI.Callback = @cBack_ROI_save;

% undo last ROI vertex
handles.undoROI.Callback = @cBack_ROI_undo;

% finish ROI
handles.finROI.Callback = @cBack_ROI_addPnt;

% export ROI
handles.expROI.Callback = @cBack_ROI_export;

% =========================================================================
% Camera menu callbacks

% save screenshot
handles.saveScrShot.Callback = @cBack_cam_screenshot;

% =========================================================================
% misc. menu callbacks

% save handles
handles.saveHndls.Callback = @cBack_misc_saveHandles; 

end
