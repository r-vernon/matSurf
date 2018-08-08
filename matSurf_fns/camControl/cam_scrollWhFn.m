function cam_scrollWhFn(src,event)
% function called when patch, panel or axis button down callback triggered
% camera locked to view angle between 2 and 18 degrees

% get camControl
camControl = getappdata(src,'camControl');

% make sure execution rate doesn't exceed frame rate
cTime = clock;
if etime(cTime,camControl.tStmp) < camControl.fRate
    return
end

% update timestamp
camControl.tStmp  = cTime;

% get rest of data
currVol = getappdata(src,'currVol');
handles = getappdata(src,'handles');

% set sensitivity
scrAmnt = event.VerticalScrollCount * -0.1 * camControl.mSens(3);

% set new view angle
% (first undo normcdf line below)
newVA = handles.brainAx.CameraViewAngle;
newVA = norminv((newVA-2)/16,10,10/3) - scrAmnt;

% make sure new view angle doesn't exceed range
newVA = max([0,min([20,newVA])]);

% TODO - replace 10s here with VA_def as below
% pass it through cumulative guassian (mu 10, sigma 10/3) so fast zooming
% at centre but slows at extremes (sigmoidal basically)
% this will also map it to between 2 and 18 deg. view angle
newVA = normcdf(newVA,10,10/3)*16 +2;

% work out how much smaller/larger axis is based on new view angle
% - xtan(a)=y1, xtan(b)=y2 -> x = y1/tan(a) = y2/tan(b)
% - y1/y2 = tan(a)/tan(b) = tan(a) * 1/tan(b) = tan(a)*cot(b)
% - set b to default VA
camControl.zFact = tand(newVA)*cotd(currVol.cam.VA_def{3});

% adjust line thickness based on zoom factor (clipped to max. 4.5)
% default thickness is 1.5 at default view angle 10deg
handles.brainROI.LineWidth = min([1.5/camControl.zFact, 4.5]);

% set it
handles.brainAx.CameraViewAngle = newVA;

% update current camera view in volume
currVol.VA_cur{3} = newVA;

% update appdata
setappdata(src,'camControl',camControl);

end