function cBack_keyPress(src,event)
% callback function to handle keypress events
% following shortcut keys defined:
% - w,     camera up (also up arrow)
% - a,     camera left (also left arrow)
% - d,     camera right (also down arrow)
% - s,     camera down (also right arrow)
% - c,     configure data overlay
% - space, rotate through data
% - t,     toggle data (normal), ROI (shift), marker (control)
% - f,     finish ROI
% - h,     hide current ROI
% - r,     ROI mode, press in ROI mode to start ROI at current vertex
% - m,     toggle mode
% - p,     take 'photo' (screenshot)
% - u,     undo ROI vertex (also backspace)
% - del,   delete ROI
% - ESC,   if drawing ROI cancel, otherwise enter data mode

% make sure we're not entering text in a textbox
if isprop(src.CurrentObject,'Style') && strcmp(src.CurrentObject.Style,'edit')
    return
end

% get data
currVol = getappdata(src,'currVol');
handles = getappdata(src,'handles');

switch event.Key
    
    case {'a','leftarrow'}
        
        if isempty(event.Modifier)
            cam_manual_rot(src,2); % rotate camera left
        elseif isscalar(event.Modifier)
            if strcmp(event.Modifier{1},'shift')
                cam_manual_pan(src,2); % pan camera left
            elseif strcmp(event.Modifier{1},'control')
                cam_manual_zoom(src,-1); % zoom camera out
            end
        end
        
    case 'c'
        
        % configure data overlay
        
    case {'d','rightarrow'}
        
        if isempty(event.Modifier)
            cam_manual_rot(src,3); % rotate camera right
        elseif isscalar(event.Modifier)
            if strcmp(event.Modifier{1},'shift')
                cam_manual_pan(src,3); % pan camera right
            elseif strcmp(event.Modifier{1},'control')
                cam_manual_zoom(src,1); % zoom camera in
            end
        end
        
    case 'f'
        
        if strcmp(handles.addROI.String,'Cont')
            cBack_ROI_addPnt(handles.finROI,[]); % spoof source as finish ROI
        end
        
    case 'h'
        
        % hide current ROI
        
    case 'm'
        
        % toggle modes depending on current mode
        if handles.dataMode.Value
            handles.roiMode.Value = 1; % turn on ROI mode
        else
            handles.dataMode.Value = 1; % turn on data mode
        end
        
    case 'p'
        
        cBack_cam_screenshot(src); % take screenshot
        
    case 'r'
        
        % if in ROI mode, start ROI at point, else switch to ROI mode
        if handles.roiMode.Value && ~isempty(handles.svEdit.String)
            cBack_ROI_addPnt(src,str2double(handles.svEdit.String));
        else
            handles.roiMode.Value = 1;
        end
        
    case {'s','downarrow'}
        
        if isempty(event.Modifier)
            cam_manual_rot(src,4); % rotate camera down
        elseif isscalar(event.Modifier)
            if strcmp(event.Modifier{1},'shift')
                cam_manual_pan(src,4); % pan camera down
            elseif strcmp(event.Modifier{1},'control')
                cam_manual_zoom(src,-1); % zoom camera out
            end
        end
        
    case {'t'}
        
        if isempty(event.Modifier) && strcmpi(handles.togData.Enable,'on')
            
            % toggle data
            handles.togData.Value = 1 - handles.togData.Value;
            cBack_data_toggle(handles.togData);
            
        elseif isscalar(event.Modifier)
            
            if strcmp(event.Modifier{1},'shift')&& strcmpi(handles.togROI.Enable,'on')
                
                % toggle ROI
                handles.togROI.Value = 1 - handles.togROI.Value;
                cBack_ROI_toggle(handles.togROI);
                
            elseif strcmp(event.Modifier{1},'control') && strcmpi(handles.togMark.Enable,'on')
                
                % toggle marker
                handles.togMark.Value = 1 - handles.togMark.Value;
                cBack_surf_toggleMarker(handles.togMark);
                
            end
        end
        
    case {'u','backspace'}
        
        if strcmp(handles.addROI.String,'Cont')
            cBack_ROI_undo(src); % undo last ROI vertex
        end
        
    case {'w','uparrow'}
        
        if isempty(event.Modifier)
            cam_manual_rot(src,1); % rotate camera up
        elseif isscalar(event.Modifier)
            if strcmp(event.Modifier{1},'shift')
                cam_manual_pan(src,1); % pan camera up
            elseif strcmp(event.Modifier{1},'control')
                cam_manual_zoom(src,1); % zoom camera in
            end
        end
        
    case 'delete'
        
        if strcmpi(handles.delData.Enable,'on')
            cBack_ROI_delete(src);
        end
        
    case 'escape'
        
        % escaped out of ROI mode, deleting ROI if it's open for editing
        if strcmp(handles.addROI.String,'Add')
            handles.dataMode.Value = 1; % turn on data mode
        else
            cBack_ROI_delete(src);
        end
        
    case 'space'
        
        % if more than one overlay, rotate between them
        if currVol.nOvrlays > 1
            handles.selData.Value = mod(handles.selData.Value,...
                currVol.nOvrlays) +1;
            cBack_data_select(handles.selData);
        end
end

end