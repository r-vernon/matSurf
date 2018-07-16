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
    currVol.cam_setCurr(...
        'CameraPosition',handles.brainAx.CameraPosition,...
        'CameraTarget',handles.brainAx.CameraTarget,...
        'CameraViewAngle',handles.brainAx.CameraViewAngle,...
        'quat',camCont.qForm);
    
    % reset status and update appdata
    camCont.mMoved = false;
    setappdata(src,'camCont',camCont);
    
    % make sure everything is up to date...
    drawnow;
    
elseif camCont.clPatch
    % no movement so if click was on patch, send intersection point for
    % processing
    
    % (for now just displaying IP)
    disp(camCont.ip);
    
end

end