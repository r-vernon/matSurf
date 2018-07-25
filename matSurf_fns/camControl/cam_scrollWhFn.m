function cam_scrollWhFn(src,event)
% function called when patch, panel or axis button down callback triggered
% camera locked to view angle between 2 and 18 degrees

% get data
camControl = getappdata(src,'camControl');
currVol = getappdata(src,'currVol');
handles = getappdata(src,'handles');

% make sure not zooming crazily...
cTime = clock;
if etime(cTime,camControl.tStmp) < camControl.fRate
    return
end

% set sensitivity
scrAmnt = event.VerticalScrollCount * -0.1 * camControl.mSens(3);

% set new view angle
% (first undo normcdf line below)
newVA = handles.brainAx.CameraViewAngle;
newVA = norminv((newVA-2)/16,10,10/3) - scrAmnt;

% make sure new view angle doesn't exceed range
newVA = max([0,min([20,newVA])]);

% update appdata
camControl.tStmp  = cTime;
setappdata(src,'camControl',camControl);

% pass it through cumulative guassian (mu 10, sigma 10/3) so fast zooming
% at centre but slows at extremes (sigmoidal basically)
% this will also map it to between 2 and 18 deg. view angle
newVA = normcdf(newVA,10,10/3)*16 +2;

% calculate % change from base (10) and apply to line thickness (base 2)
% formula actually 2 + 2*((10-newVA)/10) but simplifies to newVA/5
handles.brainROI.LineWidth = 4 - newVA/5;

% set it
handles.brainAx.CameraViewAngle = newVA;

% update current camera view in volume
currVol.VA_cur{3} = newVA;

end