function [figHandle] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================
% initialisation

% make sure everything needed is on path
allPaths = {};
pathsToAdd = '';

% work out where the freesurfer directory is...
fsPaths = {'/usr/lib/freesurfer-6.0/matlab',...
    '/usr/local/freesurfer/matlab',...
    strcat(getenv('FREESURFER_HOME'),'/matlab')};
for currPath = length(fsPaths):-1:1
    if ~exist(fsPaths{currPath},'file'), fsPaths(currPath) = []; end
end
if isempty(fsPaths)
    fsPaths{1} = input('Enter path to FreeSurfer matlab dir\n','s');
end

% create cell of all required paths
allPaths{1} = [fsPaths{1},pathsep];      % FreeSurfer matlab dir
allPaths{2} = [pwd,'/misc_fig',pathsep]; % misc. figures
allPaths{3} = [pwd,'/misc_fn',pathsep];  % misc. functions

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

% also just make sure TMPDIR set appropriately for FreeSurfer
if isempty(getenv('TMPDIR')), setenv('TMPDIR','/tmp'); end

% -------------------------------------------------------------------------

% create the figure and associated handles
[figHandle,handles] = matSurf_createFig(0);

% initialise the colormaps
handles.cmaps = cmaps;

% initialise a brainSurf object, passing it colormaps above
% this contains/will contain surface, overlays and ROIs
% saving it into allVol so can swap volumes around, but only one (in
% handles) ever operated on
allVol(1).vol = brainSurf(handles.cmaps);

% set some useful flags
surfLoaded = false; % true when surface loaded
dataLoaded = false; % true when any data overlays loaded
ROILoaded = false; % true when any ROIs added

% show the figure
figHandle.Visible = 'on';
drawnow;

% =========================================================================


% =========================================================================
% misc. functions

% updateSurface checks if showing data on surface, if yes, updates surface
% force overrides check, and forces update
    function updateSurface(force)
        
        if nargin < 1, force = false; end
        
        if force || handles.togData.Value == 1
            handles.brainPatch.FaceVertexCData = handles.vol.currOvrlay.colData;
            drawnow;
        end
    end

% =========================================================================
% surface button callbacks

% load surface
handles.addSurf.Callback = @addSurf_callback;

    function addSurf_callback(~,~)
        
        % make sure all axis limits are on auto
        handles.brainAx.XLimMode = 'auto';
        handles.brainAx.YLimMode = 'auto';
        handles.brainAx.ZLimMode = 'auto';
        
        % get ind of where to save volume
        if ~surfLoaded
            ind = 1; % no surface so save to first volume
        else
            % get new instance of brainSurf
            ind = length(allVol) + 1;
            allVol(ind).vol = brainSurf(handles.cmaps);
        end
        
        % initialise session details (TODO - get user input)
        SUBJECTS_DIR = [pwd,'/Data'];
        subject = 'R3517';
        hemi = 'rh';
        surfType = 'inflated';
        
        % set surfName, plus surf and curv to load
        surfName = strcat(subject,'_',hemi);
        fPath = fullfile(SUBJECTS_DIR,subject,'surf',{[hemi,'.',surfType],[hemi,'.curv']});
        allVol(ind).vol.surface_setDetails(fPath{1},fPath{2},surfName)
        
        % initialise a surface
        % contains triangulation (TR), graph (G) and numVertices (nVert)
        allVol(ind).vol.surface_load;
        
        % load the base overlay (curvature information), using default colours
        allVol(ind).vol.ovrlay_base;
        
        % swap out the main handles.vol with newly loaded vol
        % (saving out any changes first...)
        if ~surfLoaded
            handles.vol = allVol(ind).vol;
            surfLoaded = true; % set flag
        else
            currSurf = handles.selSurf.Value;
            allVol(currSurf).vol = handles.vol; % update w/ any changes
            handles.vol = allVol(ind).vol;
        end
            
        % make sure all cameras are off
        handles.rotCam.Value  = 0;
        handles.panCam.Value  = 0;
        handles.zoomCam.Value = 0;
        
        % display it
        set(handles.brainPatch,...
            'vertices',single(handles.vol.TR.Points),...
            'faces',single(handles.vol.TR.ConnectivityList),...
            'FaceVertexCData',handles.vol.currOvrlay.colData,...
            'VertexNormals',single(vertexNormal(handles.vol.TR)),...
            'FaceNormals',single(faceNormal(handles.vol.TR)),...
            'visible','on');
        view(handles.brainAx,90,0) % set view to Y-Z
        drawnow;
        
        % add it to pop up menu
        handles.selSurf.String = {allVol(:).vol.surfDet.surfName};
        handles.selSurf.Value = ind;

        % set the limits back to manual so doesn't have to recompute
        handles.brainAx.XLimMode = 'manual';
        handles.brainAx.YLimMode = 'manual';
        handles.brainAx.ZLimMode = 'manual';
        
    end

% save surface
handles.saveSurf.Callback = @saveSurf_callback;

    function saveSurf_callback(~,~)
        
        % open up save dialogue with default details
        tmpFig = UI_saveData(handles.vol,handles.vol.surfDet.surfName);
        
        % wait until finished saving
        uiwait(tmpFig);
        
    end

% =========================================================================


% =========================================================================
% data button callbacks

% load data
handles.addData.Callback = @addData_callback;

    function addData_callback(~,~)
        
        if ~surfLoaded, return; end
        
        % initialise a data overlay (TODO - get user input)
        % for now just ask retinotopy or coherence
        toLoad = listdlg('ListString',{'Ret','Co'});
        switch toLoad
            case 1
                toRead = [pwd,'/Data/R3517/data/Phase_RH.nii.gz'];
                cmap = 'parula';
            case 2
                toRead = [pwd,'/Data/R3517/data/Coher_RH.nii.gz'];
                cmap = 'heat';
            otherwise, return;
        end
  
        % load the base overlay (curvature information, using default colours)
        [success,ind] = handles.vol.ovrlay_add(toRead,'cmap',cmap);
        
        if success % update popupmenu and surface, plus flag
            handles.selData.String = handles.vol.ovrlayNames;
            handles.selData.Value = ind;
            updateSurface;
            dataLoaded = true;
        end
    end

% -------------------------------------------------------------------------

% select data
handles.selData.Callback = @selData_callback;

    function selData_callback(src,~)
        
        if ~dataLoaded, return; end
        
        % set currOvrlay to requested data
        [success] = handles.vol.ovrlay_set(src.Value);
        if success, updateSurface;  end
        
    end

% -------------------------------------------------------------------------

% delete data
handles.delData.Callback = @delData_callback;

    function delData_callback(~,~)
        
        if ~dataLoaded, return; end
        
        % grab index of data to remove
        toDel = handles.selData.Value;
        
        % try to delete selected overlay
        [success,ind] = handles.vol.ovrlay_remove(toDel);
        
        if success % update popupmenu and surface
            if ind == 0
                handles.selData.String = 'Select Data';
                handles.selData.Value = 1;
                updateSurface(1); % forcing update by sending '1'
                dataLoaded = false;
            else
                handles.selData.String = handles.vol.ovrlayNames;
                handles.selData.Value = ind;
                updateSurface;
            end
        end        
    end

% -------------------------------------------------------------------------

% display data toggle
handles.togData.Callback = @togData_callback;

    function togData_callback(src,~)
        
        if ~dataLoaded, return; end
        
        if src.Value == 0 % don't show data (sending '0' requests base)
            [success] = handles.vol.ovrlay_set(0);
        else % set currOvrlay to currently highlighted data
            currData = handles.selData.Value;
            [success] = handles.vol.ovrlay_set(currData);
        end
        
        if success
            updateSurface(1); % forcing update by sending '1'
        end
    end

% =========================================================================


% =========================================================================
% camera button callbacks

handles.rotCam.Callback  = @cam_callback;
handles.panCam.Callback  = @cam_callback;
handles.zoomCam.Callback = @cam_callback;

    function cam_callback(src,~)
        
        if ~surfLoaded, return; end
        
        if src.Value == 1 % switch turned on
            switch src.String
                case 'Rot.'
                    camMode = 'orbit';
                    handles.panCam.Value  = 0;
                    handles.zoomCam.Value = 0;
                case 'Pan'
                    camMode = 'pan';
                    handles.rotCam.Value  = 0;
                    handles.zoomCam.Value = 0;
                case 'Zoom'
                    camMode = 'zoom';
                    handles.rotCam.Value = 0;
                    handles.panCam.Value = 0;
                otherwise, camMode = 'nomode';
            end
            cameratoolbar(handles.matSurfFig,'SetMode',camMode);
        else
            cameratoolbar(handles.matSurfFig,'SetMode','nomode');
        end
    end

handles.resCam.Callback = @resCam_callback;

    function resCam_callback(~,~)
        
        if ~surfLoaded, return; end
        
        % turn off all current cameras and make sure no mode is selected
        handles.rotCam.Value  = 0;
        handles.panCam.Value  = 0;
        handles.zoomCam.Value = 0;
        cameratoolbar(handles.matSurfFig,'SetMode','nomode');
        
        % reset the camera
        cameratoolbar(handles.matSurfFig,'ResetCameraAndSceneLight');
        view(handles.brainAx,90,0) % set view to Y-Z
        drawnow;
    end

% =========================================================================


% =========================================================================
% misc. menu callbacks

% save handles
handles.saveHndls.Callback = @saveHndls_callback;

    function saveHndls_callback(~,~)
        
        % open up save dialogue with default details
        tmpFig = UI_saveData(handles,'handles',[],1);
        
        % wait until finished saving
        uiwait(tmpFig);
        
    end
end
