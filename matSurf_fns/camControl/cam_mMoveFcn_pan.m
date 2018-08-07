function cam_mMoveFcn_pan(src,~)
% function to call for mouse movement

% get camControl
camControl = getappdata(src,'camControl');

% make sure execution rate doesn't exceed frame rate
cTime = clock;
if etime(cTime,camControl.tStmp) < camControl.fRate
    return
end

% get rest of data
handles = getappdata(src,'handles');

% get current panel size
pSize = handles.axisPanel.Position;

% get new position relative to panel
mPos2 = (src.CurrentPoint-pSize(1:2))./(0.5*pSize(3:4)) - 1;

% calculate distance moved (dWH - delta width, height)
dWH = zeros(1,3);
dWH([1,3]) = mPos2 - camControl.mPos1;

% make sure we've moved reasonable amount...
% (doing this before scaling so don't magnify false +ves)
if hypot(dWH(1),dWH(3)) < 0.01, return; end

% scale by by zoom factor and sensitivity
dWH = dWH * camControl.zFact * camControl.mSens(2);

% multiply dWH by axis limits
dWH([1,3]) = dWH([1,3]).*[handles.brainAx.XLim(2),handles.brainAx.ZLim(2)];

% update camera position and target
set(handles.brainAx,...
    'CameraPosition', handles.brainAx.CameraPosition - dWH,...
    'CameraTarget',   handles.brainAx.CameraTarget   - dWH);

% set moved flag, then update last clicked point
camControl.mMoved = true;
camControl.mPos1  = mPos2;
camControl.tStmp  = cTime;

% update appdata
setappdata(src,'camControl',camControl);

end