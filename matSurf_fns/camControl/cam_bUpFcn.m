function cam_bUpFcn(src,~)
% function called when mouse button released on figure

% get data
camCont = getappdata(src,'camCont');

% if no mouse movement, just a click, then aim was to run
% callback, if mouse movement, then aim was to move surface so
% already taken care of with mMoveFcn

% if right click detected, for now do nothing...
if strcmp(camCont.mState,'alt')
    return;
end

% reset callbacks
src.WindowButtonMotionFcn = '';
src.WindowButtonUpFcn     = '';

if camCont.mMoved
    % mouse moved so was a camera control click, update views
    
    % get data
    currVol = getappdata(src,'currVol');
    handles = getappdata(src,'handles');

    % update current camera view in volume
    currVol.VA_cur(1:3) = {...
        handles.brainAx.CameraPosition,...
        handles.brainAx.CameraTarget,...
        handles.brainAx.CameraViewAngle};
    currVol.q_cur = camCont.qForm;
    
    % reset status and update appdata
    camCont.mMoved = false;
    setappdata(src,'camCont',camCont);
    
elseif camCont.clPatch
    
    % no movement so if click was on patch, send intersection point for
    % processing
    cBack_mode_mouseEvnt(src,camCont.ip);
    
end

end