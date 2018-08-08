function cam_manual_zoom(f_h,zoomDir)
% function to elicit manual camera movement (zooming)
%
% (req.) zoomDir, zoom direction (1 in, -1 out)

% get data
currVol = getappdata(f_h,'currVol');
camControl = getappdata(f_h,'camControl');
handles = getappdata(f_h,'handles');

% set zoom amount - TODO: user preference
zoomAmnt = zoomDir * 1;

% set new view angle
% (first undo normcdf line below)
newVA = handles.brainAx.CameraViewAngle;
newVA = norminv((newVA-2)/16,10,10/3) - zoomAmnt;

% make sure new view angle doesn't exceed range
newVA = max([0,min([20,newVA])]);

% pass it through cumulative guassian (mu 10, sigma 10/3) so fast zooming
% at centre but slows at extremes (sigmoidal basically)
% this will also map it to between 2 and 18 deg. view angle
newVA = normcdf(newVA,10,10/3)*16 +2;

% work out how much smaller/larger axis is based on new view angle
% - xtan(a)=y1, xtan(b)=y2 -> x = y1/tan(a) = y2/tan(b)
% - y1/y2 = tan(a)/tan(b) = tan(a) * 1/tan(b) = tan(a)*cot(b)
% - set b to default VA
camControl.zFact = tand(newVA)*cotd(currVol.cam.VA_def{3});

% adjust line thickness based on zoom factor
% default thickness is 2 at default view angle 10deg
handles.brainROI.LineWidth = 2 / camControl.zFact;

% set it
handles.brainAx.CameraViewAngle = newVA;

% update current camera view in volume
currVol.VA_cur{3} = newVA;

% update appdata
setappdata(f_h,'camControl',camControl);

end