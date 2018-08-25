function cam_bDownFcn(src,event)
% function called when patch, panel or axis button down callback triggered

% get camControl
f_h = getFigHandle(src);
camControl = getappdata(f_h,'camControl');

% make sure click is 'normal' or 'extend'
cState = strcmp(f_h.SelectionType(1),{'n','e'});
if ~any(cState), return; end

% get rest of data
currVol = getappdata(f_h,'currVol');
handles = getappdata(f_h,'handles');

% get state of mouse at click
camControl.mState = f_h.SelectionType;
camControl.tStmp = clock;

% get mouse pos. relative to panel
% (currPnt - min(panelSz))/0.5*range(panelSz) - 1
% if panel 0.25-1.0 and pnt 0.5, (0.5-0.25)/0.375 -1 = -1/3
pSize = handles.axisPanel.Position;
mPos = (f_h.CurrentPoint-pSize(1:2))./(0.5*pSize(3:4)) - 1;

%--------------------------------------------------------------------------
% set pointer ('fleur' is 4 arrows) and button up function

f_h.Pointer = 'fleur';
f_h.WindowButtonUpFcn = @cam_bUpFcn;

%--------------------------------------------------------------------------
% set mouse movement function if relevant button press
% (normal - LClick, alt - RClick, extend - ScrollClick/LRClick)
% only using normal (rotate) and extend (pan) currently

if cState(1) % normal, rotate (or possible click)
    
    % work out where the callback came from
    if strcmp(src.Tag,'brainPatch')
        
        % was a patch click, store intersection point
        camControl.clPatch = true;
        
        % must *undo* current quat. rotation, use q' = r*q*inv(r)
        % but actually want inv. rotmat, so doing inv(r)*q*r...
        inv_qForm = [camControl.qForm(1),-camControl.qForm(2:4)];
        ip = qMul(inv_qForm,qMul([0,event.IntersectionPoint],camControl.qForm));
        camControl.ip = nearestNeighbor(currVol.TR,ip(2:4));
        
    else
        % axis click
        camControl.clPatch = false;
    end

    % get mouse pos on 'sphere' covering panel, radius 1
    camControl.mPos1 = zeros(1,3);
    camControl.mPos1([1,3]) = mPos;
    
    % if mPos1 within circle (<=1), get depth from basic pythag., otherwise set to 0
    currPos_SSq = sum(camControl.mPos1.^2);
    if currPos_SSq <= 1, camControl.mPos1(2) = -sqrt(1-currPos_SSq); end
    
    f_h.WindowButtonMotionFcn = @cam_mMoveFcn_rot;
    
else % extend, pan
    
    % set mouse position
    camControl.mPos1 = mPos;
    
    f_h.WindowButtonMotionFcn = @cam_mMoveFcn_pan;
end

% update appdata
setappdata(f_h,'camControl',camControl);

drawnow;

end