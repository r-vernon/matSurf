function [figHandle,handles] = matSurf()

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
handles.vol = brainSurf(cmaps);

% set some useful flags
surfLoaded = false; % true when surface loaded
dataLoaded = false; % true when any data overlays loaded
ROILoaded = false; % true when any ROIs added

% show the figure
set(figHandle,'Visible','on');

% =========================================================================


% =========================================================================
% misc. functions

% updateSurface checks if showing data on surface, if yes, updates surface
% force overrides check, and forces update
    function updateSurface(force)
        
        if nargin < 1, force = false; end
        
        if force || handles.togData.Value == 1
            set(handles.brainPatch,'FaceVertexCData',handles.vol.currOvrlay.colData);
            drawnow;
        end
    end

% =========================================================================
% surface button callbacks

% load surface
set(handles.addSurf,'Callback',@addSurf_callback);

    function addSurf_callback(src,event)
        
        % initialise a surface (TODO - get user input)
        % contains triangulation (TR), graph (G) and numVertices (nVert)
        handles.vol.surface_load;
        
        % load the base overlay (curvature information), using default colours
        handles.vol.ovrlay_base;
        
        % make sure all cameras are off
        set([handles.rotCam,handles.panCam,handles.zoomCam],'Value',0);
        
        % display it
        set(handles.brainPatch,'vertices',handles.vol.TR.Points,...
            'faces',handles.vol.TR.ConnectivityList,...
            'FaceVertexCData',handles.vol.currOvrlay.colData,...
            'visible','on');
        view(handles.brainAx,90,0) % set view to Y-Z
        drawnow;
        
        % set flag
        surfLoaded = true;
    end

% =========================================================================


% =========================================================================
% data button callbacks

% load data
set(handles.addData,'Callback',@addData_callback);

    function addData_callback(src,event)
        
        if ~surfLoaded, return; end
        
        % initialise a data overlay (TODO - get user input)
        % for now just ask retinotopy or coherence
        toLoad = listdlg('ListString',{'Ret','Co'});
        switch toLoad
            case 1
                toRead = [handles.vol.surfDet.SUBJECTS_DIR,'/data/Phase_RH.nii.gz'];
                cmap = 'parula';
            case 2
                toRead = [handles.vol.surfDet.SUBJECTS_DIR,'/data/Coher_RH.nii.gz'];
                cmap = 'heat';
            otherwise, return;
        end
  
        % load the base overlay (curvature information, using default colours)
        [success,ind] = handles.vol.ovrlay_add(toRead,'cmap',cmap);
        
        if success % update popupmenu and surface, plus flag
            set(handles.selData,'String',handles.vol.ovrlayNames,'Value',ind);
            updateSurface;
            dataLoaded = true;
        end
    end

% -------------------------------------------------------------------------

% select data
set(handles.selData,'Callback',@selData_callback);

    function selData_callback(src,event)
        
        if ~dataLoaded, return; end
        
        % set currOvrlay to requested data
        [success] = handles.vol.ovrlay_set(src.Value);
        if success, updateSurface;  end
        
    end

% -------------------------------------------------------------------------

% delete data
set(handles.delData,'Callback',@delData_callback);

    function delData_callback(src,event)
        
        if ~dataLoaded, return; end
        
        % grab index of data to remove
        toDel = get(handles.selData,'Value');
        
        % try to delete selected overlay
        [success,ind] = handles.vol.ovrlay_remove(toDel);
        
        if success % update popupmenu and surface
            if ind == 0
                set(handles.selData,'String','Select Data','Value',1);
                updateSurface(1); % forcing update by sending '1'
                dataLoaded = false;
            else
                set(handles.selData,'String',handles.vol.ovrlayNames,'Value',ind);
                updateSurface;
            end
        end        
    end

% -------------------------------------------------------------------------

% display data toggle
set(handles.togData,'Callback',@togData_callback);

    function togData_callback(src,event)
        
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

set([handles.rotCam,handles.panCam,handles.zoomCam],...
    'Callback',@cam_callback);

    function cam_callback(src,event)
        
        if ~surfLoaded, return; end
        
        if src.Value == 1 % switch turned on
            switch src.String
                case 'Rot.'
                    camMode = 'orbit';
                    set([handles.panCam,handles.zoomCam],'Value',0);
                case 'Pan', camMode = 'pan';
                    set([handles.rotCam,handles.zoomCam],'Value',0);
                case 'Zoom', camMode = 'zoom';
                    set([handles.rotCam,handles.panCam],'Value',0);
                otherwise, camMode = 'nomode';
            end
            cameratoolbar(handles.matSurfFig,'SetMode',camMode);
        else
            cameratoolbar(handles.matSurfFig,'SetMode','nomode');
        end
    end

set(handles.resCam,'Callback',@resCam_callback);

    function resCam_callback(src,event)
        
        if ~surfLoaded, return; end
        
        % turn off all current cameras and make sure no mode is selected
        set([handles.rotCam,handles.panCam,handles.zoomCam],'Value',0);
        cameratoolbar(handles.matSurfFig,'SetMode','nomode');
        
        % reset the camera
        cameratoolbar(handles.matSurfFig,'ResetCameraAndSceneLight');
        view(handles.brainAx,90,0) % set view to Y-Z
        drawnow;
    end

% =========================================================================

end
