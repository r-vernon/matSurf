function cBack_surf_camReset(src,~)

% make sure volumes loaded
f_h = getFigHandle(src);
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
camCont = getappdata(f_h,'camCont');
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% set current view to default view
set(handles.brainAx,currVol.cam.NA,currVol.cam.VA_def);
handles.xForm.Matrix = qRotMat(currVol.cam.q_def);

% tell surface we've reset
currVol.cam_reset;

% update appdata
camCont.qForm = currVol.cam.q_def;
setappdata(f_h,'camCont',camCont);

setStatusTxt('camera reset');

drawnow;

end