function cam_scrollWhFn(src,event)
% function called when patch, panel or axis button down callback triggered
% camera locked to view angle between 2 and 18 degrees

% get data
camCont = getappdata(src,'camCont');
currVol = getappdata(src,'currVol');
handles = getappdata(src,'handles');

% make sure not zooming crazily...
cTime = clock;
if etime(cTime,camCont.tStmp) < camCont.fRate
    return
end

% set sensitivity
scrAmnt = event.VerticalScrollCount * -0.1 * 1.5; %camCont.mSens(3);

% set new view angle
newVA = camCont.zVal - scrAmnt;

% make sure new view angle doesn't exceed range
newVA = max([0,min([20,newVA])]);

% update appdata
camCont.zVal = newVA;
camCont.tStmp  = cTime;
setappdata(src,'camCont',camCont);

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