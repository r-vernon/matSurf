function cBack_cam_swMode(src)

% make sure volumes loaded
f_h = getFigHandle(src);
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
handles = getappdata(f_h,'handles');

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
        otherwise
            camMode = 'nomode';
    end
    
    cameratoolbar(handles.matSurfFig,'SetMode',camMode);
    
else
    
    cameratoolbar(handles.matSurfFig,'SetMode','nomode');
    
end

end