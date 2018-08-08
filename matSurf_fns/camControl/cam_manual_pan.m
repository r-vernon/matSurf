function cam_manual_pan(f_h,panDir)
% function to elicit manual camera movement (panning)
%
% (req.) panDir, panning direction (1 up, 2 left, 3 right, 4 down)

% get data
currVol = getappdata(f_h,'currVol');
camControl = getappdata(f_h,'camControl');
handles = getappdata(f_h,'handles');

% wipe the stored view (if any)
camControl.view = '';

% set pan amount - TODO: user preference
pAmnt = 0.1 * camControl.zFact;

% set rotation vector (u)
switch panDir
    case 1 % up      
        dWH = [0,0,pAmnt];
    case 2 % left    
        dWH = [-pAmnt,0,0];
    case 3 % right   
        dWH = [pAmnt,0,0];
    otherwise % down 
        dWH = [0,0,-pAmnt];
end

% multiply dWH by axis limits
dWH([1,3]) = dWH([1,3]).*[handles.brainAx.XLim(2),handles.brainAx.ZLim(2)];

% update camera position and target
set(handles.brainAx,...
    'CameraPosition', handles.brainAx.CameraPosition - dWH,...
    'CameraTarget',   handles.brainAx.CameraTarget   - dWH);
currVol.VA_cur(1:2) = {handles.brainAx.CameraPosition,...
        handles.brainAx.CameraTarget};
    
% update appdata
setappdata(f_h,'camControl',camControl);

end