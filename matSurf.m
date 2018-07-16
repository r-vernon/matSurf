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
mSens   - mouse sensitivity for (order): rotation, panning, zooming
mMoved  - true if mouse moved
mPos1   - mouse position at click (wrt. axis (normal Cl.) or fig (extend Cl.)
mState  - normal (LClick), extend (L+R Click, ScrWh Click), alt (RClick)
clPatch - true if click came from patch
ip      - intersection point between click/patch if clicked patch
qForm   - rotation matrix in quaternion form
tStmp   - time stamp of button down
figSize - size of figure (should be normalised units)
fRate   - frame rate limit of camera
%}
camCont = struct(...
    'mSens',[1.5,1.0,1.0],'mState','','mPos1',[],'mMoved',false,...
    'clPatch',false,'ip',[],'qForm',[],'tStmp',[],'figSize',[],'fRate',1/24);
setappdata(f_h,'camCont',camCont);

% show the figure
f_h.Visible = 'on';
drawnow;

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback  = @cBack_surf_add;

% reset camera
handles.resCam.Callback   = @cBack_surf_camReset;

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
handles.addROI.Callback = @cBack_setMode;

% finish ROI
handles.finROI.Callback = @cBack_ROI_addPnt;

% =========================================================================
% misc. menu callbacks

% save handles
handles.saveHndls.Callback = @cBack_misc_saveHandles; 

end
