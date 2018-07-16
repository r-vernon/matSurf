function [mS_f] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================

% set all paths and make sure freesurfer is available
[baseDir,~,~] = fileparts(mfilename('fullpath'));
matSurf_pathSetup(baseDir);

% create the figure and associated handles
[mS_f,handles] = mS_create_fig(0);

% initialise the colormaps
setappdata(mS_f,'cmaps',cmaps);

% initialise a volStore class, this will store handles to all surface vols
% loaded, so can swap between them
setappdata(mS_f,'allVol',mS_volStore);

% initialise camera control
camCont = camControl(handles.xForm);
setappdata(mS_f,'camCont',camCont);

% show the figure
mS_f.Visible = 'on';
drawnow;

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback = @cBack_surf_add;

% reset camera
handles.resCam.Callback = @camCont.resetState;

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
