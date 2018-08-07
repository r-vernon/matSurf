
f = handles.matSurfFig;
ax = handles.brainAx;

% work out how much smaller/larger axis is based on view angle alone
%{
xtan(a)=y1, xtan(b)=y2 -> x = y1/tan(a) = y2/tan(b)
y1/y2 = tan(a)/tan(b) = tan(a) * 1/tan(b) = tan(a)*cot(b)
set b to hardcoded 10deg (orig. VA), so know if moved x1 in current VA 
would be equiv. to x2 at orig. VA
%}
vaChange = tand(ax.CameraViewAngle)*cotd(10);


% get relavent sizes
