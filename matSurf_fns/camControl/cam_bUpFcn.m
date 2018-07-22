function cam_bUpFcn(src,~)
% function called when mouse button released on figure

% get data
camControl = getappdata(src,'camControl');

% if no mouse movement, just a click, then aim was to run
% callback, if mouse movement, then aim was to move surface so
% already taken care of with mMoveFcn

% if right click detected, for now do nothing...
if strcmp(camControl.mState,'alt')
    return;
end

% reset callbacks
src.WindowButtonMotionFcn = '';
src.WindowButtonUpFcn     = '';

if camControl.mMoved
    % mouse moved so was a camera control click, update views
    
    % get data
    currVol = getappdata(src,'currVol');
    handles = getappdata(src,'handles');

    % update current camera view in volume
    currVol.VA_cur(1:3) = {...
        handles.brainAx.CameraPosition,...
        handles.brainAx.CameraTarget,...
        handles.brainAx.CameraViewAngle};
    currVol.q_cur = camControl.qForm;
    
    % reset status and update appdata
    camControl.mMoved = false;
    setappdata(src,'camControl',camControl);
    
elseif camControl.clPatch
    
    % no movement so if click was on patch, send intersection point for
    % processing
    cBack_mode_mouseEvnt(src,camControl.ip);
    
end

drawnow;

end