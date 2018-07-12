function cam_rest_cBack(src)

% make sure volumes loaded
f_h = getFigHandle(src);
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% turn off all current cameras and make sure no mode is selected
handles.rotCam.Value  = 0;
handles.panCam.Value  = 0;
handles.zoomCam.Value = 0;
cameratoolbar(handles.matSurfFig,'SetMode','nomode');

% reset the camera
view(handles.brainAx,90,0) % set view to Y-Z

% set target to centroid
handles.brainAx.CameraTarget = currVol.centroid;

drawnow;

end