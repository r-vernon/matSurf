function cBack_keyPress(src,event)
% callback function to handle keypress events
% following shortcut keys defined:
% - w,     camera up (also up arrow)
% - a,     camera left (also left arrow)
% - d,     camera right (also down arrow)
% - s,     camera down (also right arrow)
% - c,     config data
% - space, rotate through data
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
        
        cam_manual_rot(src,2); % move camera left
        
    case {'d','rightarrow'}
        
        cam_manual_rot(src,3); % move camera right
        
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
        
        cam_manual_rot(src,4); % move camera down
        
    case {'u','backspace'}
        
        if strcmp(handles.addROI.String,'Cont')
            cBack_ROI_undo(src); % undo last ROI vertex
        end
        
    case {'w','uparrow'}
        
        cam_manual_rot(src,1); % move camera up
        
    case 'delete'
        
        cBack_ROI_delete(src);
        
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