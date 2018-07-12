function [mS_f] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================

% set all paths and make sure freesurfer is available
mS_setup_paths;

% create the figure and associated handles
[mS_f,handles] = mS_create_fig(0);

% initialise the colormaps
setappdata(mS_f,'cmaps',cmaps);

% initialise a volStore class, this will store handles to all surface vols
% loaded, so can swap between them
setappdata(mS_f,'allVol',mS_volStore);

% show the figure
mS_f.Visible = 'on';
drawnow;

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback = @(src,~) cBack_surf_add(src);

% save surface
handles.saveSurf.Callback = @(src,~) cBack_surf_save(src);

% =========================================================================
% data button callbacks

% load data
handles.addData.Callback = @(src,~) cBack_data_add(src);

% select data
handles.selData.Callback = @(src,~) cBack_data_select(src);

% delete data
handles.delData.Callback = @(src,~) cBack_data_delete(src);

% display data toggle
handles.togData.Callback = @(src,~) cBack_data_toggle(src);

% =========================================================================
% ROI button callbacks

% add ROI
handles.addROI.Callback = @(src,~) cBack_setMode(src);

% finish ROI
handles.finROI.Callback = @(src,event) cBack_ROI_addPnt(src,event,true);

% =========================================================================
% camera button callbacks

handles.rotCam.Callback  = @(src,~) cBack_cam_swMode(src);
handles.panCam.Callback  = @(src,~) cBack_cam_swMode(src);
handles.zoomCam.Callback = @(src,~) cBack_cam_swMode(src);

handles.resCam.Callback = @(src,~) cBack_cam_rest(src);

% =========================================================================
% misc. menu callbacks

% save handles
handles.saveHndls.Callback = @(src,~) cBack_misc_saveHandles(src); 

end
