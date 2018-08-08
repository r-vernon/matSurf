function mS_stateControl(f_h,updateCode)
% function that manages the state of UI elements depending on current
% status 
%
% (will only set things to default, e.g. if all overlays are removed, it
% will reset selData.String to 'Select Data', but if overlays remain it's
% up to the remove overlay function to set selData.String accordingly)
%
% (req.) f_h, figure handle to main matSurf figure
% (req.) updateCode, code to indicate what's changed, codes are:
%        - sa, sr, sc, sl - add/remove/change/load surface
%        - da, dr         - add first/remove only data overlay
%        - ra, rr         - add first/remove only ROI

if ~ischar(updateCode) || length(updateCode) ~= 2
    return
end

%--------------------------------------------------------------------------

% The states are as follows:
%---------------------------
%
% % Callback (figure mouse click/scroll callbacks)
% 0 - disable
% 1 - enable
%
% Mode (data/ROI mode panel):
% -1 - disable and reset
%  0 - reset only
% +1 - enable and reset
%
% Surface:
% -2 - removing one of *multiple* surfaces
% -1 - removing *only* surface
%  0 - switching between *multiple* surfaces (or loading saved surface)
% +1 - adding *first* surface
% +2 - adding *additional* surface
%
% Data:
% -2 - disable and reset (everything off)
% -1 - removing *only* data overlay
% +1 - adding *first* data overlay
% +2 - enable and reset (all but 'add' off)
%
% ROI:
% -2 - disable and reset (everything off)
% -1 - removing *only* ROI
% +1 - adding *first* ROI
% +2 - enable and reset (all but 'add' off)
%
% BrainPatch:
% 0 - reset
% 1 - load first instance, or change instance

%--------------------------------------------------------------------------

% load in data
allVol     = getappdata(f_h,'allVol');
camControl = getappdata(f_h,'camControl');
handles    = getappdata(f_h,'handles');

% load in current vol if possible
if isappdata(f_h,'currVol')
    currVol = getappdata(f_h,'currVol'); 
end

% work out what to call
updateCode = lower(updateCode);

switch updateCode(1)
    
    case 's' % surface
        
        switch updateCode(2)
            case 'a' % add
                if allVol.nVol == 1
                    switchSurfState(1);  % added first surface
                else
                    switchSurfState(2);  % added additional surface
                end
            case 'r' % remove
                if allVol.nVol == 0
                    switchSurfState(-1); % removed only surface
                else
                    switchSurfState(-2); % removed additional surface
                end
            case {'c','l'} % change/load
                switchSurfState(0);      % surface changed, or existing surface loaded
        end
        
    case 'd' % data overlay
        
        switch updateCode(2)
            case 'a' % add
                switchDataState(1);  % added first data overlay
            case 'r' % remove
                switchDataState(-1); % removed only data overlay
        end
        
    case 'r' % ROI
        
        switch updateCode(2)
            case 'a' % add
                switchROIState(1);  % added first ROI
            case 'r' % remove
                switchROIState(-1); % removed only ROI
        end
end

%--------------------------------------------------------------------------
% deal with callback states
%
% 0 - disable
% 1 - enable

    function switchCallbackState(newState)
        
        switch newState
            case 0 % disable
                
                handles.matSurfFig.WindowKeyReleaseFcn  = '';
                handles.matSurfFig.WindowScrollWheelFcn = '';
                handles.axisPanel.ButtonDownFcn         = '';
                handles.brainPatch.ButtonDownFcn        = '';
                
            case 1 % enable
                
                handles.matSurfFig.WindowKeyReleaseFcn  = @cBack_keyPress;
                handles.matSurfFig.WindowScrollWheelFcn = @cam_scrollWhFn;
                handles.axisPanel.ButtonDownFcn         = @cam_bDownFcn;
                handles.brainPatch.ButtonDownFcn        = @cam_bDownFcn;
        end
    end

%--------------------------------------------------------------------------
% deal with mode states
%
% -1 - disable and reset
%  0 - reset only
% +1 - enable and reset

    function switchModeState(newState)
        
        % in any state, reset back to data mode
        handles.dataMode.Value = 1;
        
        switch newState
            case -1 % disable
                set(handles.modePanel.Children,'Enable','off');
            case  1  % enable
                set(handles.modePanel.Children,'Enable','on');
        end
    end

%--------------------------------------------------------------------------
% deal with surface states
%
% -2 - removing one of *multiple* surfaces
% -1 - removing *only* surface
%  0 - switching between *multiple* surfaces (or loading saved surface)
% +1 - adding *first* surface
% +2 - adding *additional* surface

    function switchSurfState(newState)
        
        % combine some key handles so can turn all on/off as needed
        keyHandles = [handles.saveSurf,handles.delSurf,handles.selSurf,...
            handles.svTxt,handles.svEdit,handles.togMark,handles.resCam,...
            handles.saveScrShot];
        
        switch newState
            case -2 % removing one of multiple surfaces
                
                handles.matSurfFig.Name = ['matSurf - ',currVol.surfDet.surfName];
                
                switchBrainPatchState(1);         % new or changed instance
                switchModeState(0);               % reset only
                checkVertState;
                checkDataState;
                checkROIState;
                                
            case -1 % removed only surface
                
                handles.matSurfFig.Name = 'matSurf';
                
                switchBrainPatchState(0);         % reset
                set(keyHandles,'Enable','off');
                handles.svEdit.UIContextMenu = '';
                switchCallbackState(0);           % disable
                switchModeState(-1);              % disable and reset
                set(handles.selSurf,...
                    'String','Select Surface','Value',1);
                checkVertState(true);             % force reset
                switchDataState(-2);              % disable and reset
                switchROIState(-2);               % disable and reset
                setStatusTxt(handles.statTxt,'no data loaded');
                
            case  0 % switching between multiple surfaces
                
                handles.matSurfFig.Name = ['matSurf - ',currVol.surfDet.surfName];
                
                switchBrainPatchState(1);         % new or changed instance
                switchModeState(0);               % reset only
                checkVertState;
                checkDataState;
                checkROIState;
                
            case  1 % adding first surface
                
                handles.matSurfFig.Name = ['matSurf - ',currVol.surfDet.surfName];
                
                switchBrainPatchState(1);         % new or changed instance
                set(keyHandles,'Enable','on');
                handles.svEdit.UIContextMenu = handles.cpMenu;
                switchCallbackState(1);           % enable
                switchModeState(1);               % enable and reset
                switchDataState(2);               % enable and reset
                switchROIState(2);                % enable and reset

            case  2 % adding additional surface
                
                handles.matSurfFig.Name = ['matSurf - ',currVol.surfDet.surfName];
                
                switchBrainPatchState(1);         % new or changed instance
                switchModeState(0);               % reset only
                checkVertState(true);             % force reset
                switchDataState(2);               % enable and reset
                switchROIState(2);                % enable and reset
        end
    end

    function checkVertState(forceReset)
        % checks to see if currVol has vertex selected, if it does it sets
        % that vertex to 'active', otherwise it sets it to empty
        % (can optionally force reset with forceReset arg)
        
        if nargin == 0
            forceReset = false;
        end
        
        if ~isempty(currVol.selVert) && ~forceReset
            
            % work out if marker should be visible or not
            if handles.togMark.Value == 1
                handles.markPatch.Visible = 'on';
            else
                handles.markPatch.Visible = 'off';
            end
            
            handles.svEdit.String = num2str(currVol.selVert);
            cBack_mode_mouseEvnt(f_h,currVol.selVert);
            
        else
            handles.svEdit.String = '';
            set(handles.markPatch,...
                'vertices',[],'faces',[],...
                'VertexNormals',[],'FaceNormals',[],...
                'FaceVertexCData',[]);
        end
    end

%--------------------------------------------------------------------------
% deal with data states
%
% -2 - disable and reset (everything off)
% -1 - removing *only* data overlay
% +1 - adding *first* data overlay
% +2 - enable and reset (all but 'add' off)

    function checkDataState
        % checks data state and sets it accordingly
        
        if currVol.nOvrlays == 0
            
            % disable buttons and reset select data
            switchDataState(-1);
            
        else
            
            % enable buttons
            switchDataState(1);
            
            % get ind of curr overlay
            cOvrlay = currVol.ovrlay_find(currVol.currOvrlay.name);
            
            % set select data and toggle data accordingly
            handles.selData.String = currVol.ovrlayNames;
            if cOvrlay == 0
                % current overlay is base, so set data select to first
                % overlay and make it hidden
                handles.selData.Value = 1;
                handles.togData.Value = 0;
            else
                % show the current loaded overlay
                handles.selData.Value = cOvrlay;
                handles.togData.Value = 1;
            end
        end
    end

    function switchDataState(newState)
        
        % combine some key handles so can turn all on/off as needed
        keyHandles = [handles.delData,handles.selData,handles.cfgData,...
            handles.saveData,handles.togData];
        
        if abs(newState) == 2 % if asked to disable or enable, and reset
            
            if newState == 2
                handles.addData.Enable = 'on';  % enable
            else
                handles.addData.Enable = 'off'; % disable
            end
            newState = -1; % reset
            
        end

        switch newState
            case -1 % removed only data overlay
                
                set(keyHandles,'Enable','off');
                set(handles.selData,'String','Select Data','Value',1);
                handles.togData.Value = 1;

            case  1 % adding first data overlay
                
                set(keyHandles,'Enable','on');
        end
    end

%--------------------------------------------------------------------------
% deal with ROI states
%
% -2 - disable and reset (everything off, e.g. if no surfaces loaded)
% -1 - removing *only* ROI
% +1 - adding *first* ROI
% +2 - enable and reset (all but 'add' off, e.g. if loaded 1st surface)

    function checkROIState
        % checks ROI state and sets it accordingly
        
        if currVol.nROIs == 0
            
            % disable buttons and reset select data
            switchROIState(-1);
            
        else
            
            % enable buttons
            switchROIState(1);
            
            set(handles.selROI,'String',currVol.roiNames,'Value',currVol.nROIs);
            vertexCoords = currVol.ROI_get;
            set(handles.brainROI,...
                'XData',vertexCoords(:,1),...
                'YData',vertexCoords(:,2),...
                'ZData',vertexCoords(:,3));
            
            % check if visible ROI open to editing
            ROI_stateControl(handles);
            
        end
    end

    function switchROIState(newState)
        
        % combine some key handles so can turn all on/off as needed
        keyHandles = [handles.undoROI,handles.finROI,handles.impROI,...
            handles.expROI,handles.delROI,handles.selROI,handles.cfgROI,...
            handles.saveROI,handles.togROI];
        
        if abs(newState) == 2 % if asked to disable or enable, and reset
            
            if newState == 2
                handles.addROI.Enable = 'on';  % enable
            else
                handles.addROI.Enable = 'off'; % disable
            end
            newState = -1; % reset
            
        end
        
        switch newState
            case -1 % removed only ROI
                
                % set addROI button back to 'Add'
                handles.addROI.String = 'Add';
                
                set(keyHandles,'Enable','off');
                set(handles.selROI,'String','Select ROI','Value',1);
                handles.togROI.Value = 1;
                set(handles.brainROI,'XData',[],'YData',[],'ZData',[]);
                
            case  1 % adding first ROI
                
                set(keyHandles,'Enable','on');
                if handles.togROI.Value == 1
                    handles.brainROI.Visible = 'on';
                else
                    handles.brainROI.Visible = 'off';
                end
        end
    end

%--------------------------------------------------------------------------
% deal with brain patch state
%
% 0 - reset
% 1 - load first instance, or change instance

    function switchBrainPatchState(newState)
        
        % whatever happens reset status states
        camControl.mMoved = false;
        camControl.clPatch = false;
        
        switch newState
            case 0 % reset
                
                % reset camera qForm and zoom factor
                camControl.qForm = [];
                camControl.zFact = 1;
                
                set(handles.brainPatch,...
                    'vertices',[],'faces',[],...
                    'VertexNormals',[],'FaceNormals',[],...
                    'FaceVertexCData',[],...
                    'visible','off');
                
            case 1 % loaded first instance or changed instance
                
                % set camera to current settings
                % (if first instance, current will be default anyway)
                set(handles.brainAx,currVol.cam.NA,currVol.VA_cur);
                handles.xForm.Matrix = qRotMat(currVol.q_cur);
                camControl.qForm = currVol.q_cur;
                camControl.zFact = tand(currVol.VA_cur{3}) * ...
                    cotd(currVol.cam.VA_def{3});
                
                % update axis limits
                xyzLim = [-1,1] * currVol.xyzLim;
                set(handles.brainAx,'XLim',xyzLim,'YLim',xyzLim,'ZLim',xyzLim);
                
                set(handles.brainPatch,...
                    'vertices',currVol.TR.Points,...
                    'faces',currVol.TR.ConnectivityList,...
                    'FaceVertexCData',currVol.currOvrlay.colData,...
                    'VertexNormals',vertexNormal(currVol.TR),...
                    'FaceNormals',faceNormal(currVol.TR),...
                    'visible','on');
                
                % adjust line thickness based on zoom factor (clipped to max. 4.5)
                handles.brainROI.LineWidth = min([1.5/camControl.zFact, 4.5]);
                
                % update lighting...
                
                % set options for light position
                % - for left/right, half max X axis limit
                % - for 'depth', twice min Y axis limit
                lPos = [xyzLim(2)/2, xyzLim(1)*2];
                
                % for each of the 4 lights, keep depth constant, alternate 
                % between +- L/R and +- UD
                handles.llLight.Position = [-lPos(1), lPos(2), -lPos(1)];
                handles.ulLight.Position = [-lPos(1), lPos(2),  lPos(1)];
                handles.lrLight.Position = [ lPos(1), lPos(2), -lPos(1)];
                handles.urLight.Position = [ lPos(1), lPos(2),  lPos(1)];
        end
        
        % update camera appdata
        setappdata(f_h,'camControl',camControl);
    end

end