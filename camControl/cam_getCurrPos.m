function [currPos] = cam_getCurrPos(a_h,xyzLim)
% function to get current mouse position as a function of set
% axis limits (where 0 = centre, 1 = at limits)
%
% (req.) a_h,     axis handle
% (req.) xyzLim,  axis limits
% (ret.) currPos, current mouse position

currPos = zeros(1,3);

% grab x (1, hor.), z (3, ver.), dividing by axis limits
% y (2, depth) will just be set to far front of axis, useless
currPos([1,3]) = a_h.CurrentPoint(1,[1,3])/xyzLim;

% if sum of squares > 1, outside axis limits, leave depth (y)
% as 0, otherwise use basic pythag. to set depth as if on sphere
currPos_SSq = sum(currPos.^2);
if currPos_SSq <= 1
    currPos(2) = -sqrt(1-currPos_SSq);
end

end