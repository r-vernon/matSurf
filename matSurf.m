function [mS_f] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================
% set all paths and make sure freesurfer is available

allPaths = {};
pathsToAdd = '';

%----------------------------------------------------
% first work out where the FreeSurfer directory is...

% set some possible FreeSurfer paths (in ascending probability order)
fsPaths = {...
    '/usr/lib/freesurfer-6.0/matlab',...
    '/usr/local/freesurfer/matlab',...
    strcat(getenv('FREESURFER_HOME'),'/matlab')...
    };

% work backworks through list, testing if each path exists (de. if not)
for currPath = length(fsPaths):-1:1
    if ~exist(fsPaths{currPath},'file'), fsPaths(currPath) = []; end
end

% if haven't found suitable path, ask user for it
if isempty(fsPaths)
    fsPaths{1} = input('Enter path to FreeSurfer matlab dir\n','s');
end

% also just make sure TMPDIR set appropriately for FreeSurfer
% (on my work machine, TMPDIR will default to somewhere without write
% access so causes error)
if isempty(getenv('TMPDIR'))
    setenv('TMPDIR','/tmp'); 
end

%---------------------------------------
% add all remaining paths to matlab path

% create cell of all required paths
allPaths{1} = [fsPaths{1},          pathsep]; % FreeSurfer matlab dir
allPaths{2} = [pwd, '/matSurf_fns', pathsep]; % matSurf callback fns
allPaths{3} = [pwd, '/misc_figs',   pathsep]; % misc. figures
allPaths{4} = [pwd, '/misc_fns',    pathsep]; % misc. functions

% work out which paths need adding
for currPath = 1:length(allPaths)
    if ~contains(path,allPaths{currPath})
        pathsToAdd = strcat(pathsToAdd,allPaths{currPath});
    end
end

% add them (doing all in one go should be faster than individually)
if ~isempty(pathsToAdd)
    addpath(pathsToAdd);
    fprintf(['\nAdding following to Matlab path: \n',strrep(pathsToAdd,':','\n'),'\n']);
end

% =========================================================================

% create the figure and associated handles
[mS_f,handles] = create_mS_fig(0);

% initialise the colormaps
setappdata(mS_f,'cmaps',cmaps);

% initialise a volStore class, this will store handles to all surface vols
% loaded, so can swap between them
setappdata(mS_f,'allVol',volStore);

% show the figure
mS_f.Visible = 'on';
drawnow;

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback = @(src,~) surf_add_cBack(src);

% save surface
handles.saveSurf.Callback = @(src,~) surf_save_cBack(src);

% =========================================================================
% data button callbacks

% load data
handles.addData.Callback = @(src,~) data_add_cBack(src);

% select data
handles.selData.Callback = @(src,~) data_select_cBack(src);

% delete data
handles.delData.Callback = @(src,~) data_delete_cBack(src);

% display data toggle
handles.togData.Callback = @(src,~) data_toggle_cBack(src);

% =========================================================================
% ROI button callbacks

% add ROI
handles.addROI.Callback = @(src,~) setMode_cBack(src);

% finish ROI
handles.finROI.Callback = @(src,event) ROI_addPnt_cBack(src,event,true);

% =========================================================================
% camera button callbacks

handles.rotCam.Callback  = @(src,~) cam_swMode_cBack(src);
handles.panCam.Callback  = @(src,~) cam_swMode_cBack(src);
handles.zoomCam.Callback = @(src,~) cam_swMode_cBack(src);

handles.resCam.Callback = @(src,~) cam_rest_cBack(src);

% =========================================================================
% misc. menu callbacks

% save handles
handles.saveHndls.Callback = @(src,~) misc_saveHandles_cBack(src); 

end
