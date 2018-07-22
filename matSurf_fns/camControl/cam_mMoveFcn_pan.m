function cam_mMoveFcn_pan(src,~)
% function to call for mouse movement

% get data
camControl = getappdata(src,'camControl');
handles = getappdata(src,'handles');

% get new position
mPos2 = src.CurrentPoint;
cTime = clock;

% calculate distance moved (dWH - delta width, height)
dWH = zeros(1,3);
dWH([1,3]) = (mPos2 - camControl.mPos1)./src.Position(3:4);

% make sure we've moved reasonable amount...
% (doing this before scaling so don't magnify false +ves)
if hypot(dWH(1),dWH(3)) < 0.01 || etime(cTime,camControl.tStmp) < camControl.fRate
    return
end

% scale by sensitivity, then update camera position and target
dWH = dWH * 100 * camControl.mSens(2);
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