function cBack_surf_camReset(src,~)

% get data
f_h = getFigHandle(src);
camControl = getappdata(f_h,'camControl');
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% set current view to default view
set(handles.brainAx,currVol.cam.NA,currVol.cam.VA_def);
handles.xForm.Matrix = qRotMat(currVol.cam.q_def);

% tell surface we've reset
currVol.cam_reset;

% update appdata
camControl.qForm = currVol.cam.q_def;
setappdata(f_h,'camControl',camControl);

setStatusTxt('camera reset');

drawnow;

end