function cam_bDownFcn(src,event)
% function called when patch or axis button down callback triggered

% get data
f_h = getFigHandle(src);
camCont = getappdata(f_h,'camCont');
handles = getappdata(f_h,'handles');

% get state of mouse at click
camCont.mState = f_h.SelectionType;
camCont.tStmp = clock;

% set mouse movement function if relevant button press
% (normal - LClick, alt - RClick, extend - ScrollClick/LRClick)
% only using normal (rotate) and extend (pan) currently

switch camCont.mState(1)
    case 'n'  % normal, rotate (or possible click)
        
        % work out where the callback came from
        if strcmp(src.Tag,'brainPatch') 

            % was a patch click, store intersection point
            camCont.clPatch = true;
            
            % must *undo* current quat. rotation, use q' = r*q*inv(r)
            % but actually want inv. rotmat, so doing inv(r)*q*r...
            inv_qForm = [camCont.qForm(1),-camCont.qForm(2:4)];
            ip = qMul(inv_qForm,qMul([0,event.IntersectionPoint],camCont.qForm));
            camCont.ip = ip(2:4);        
            
        else            
            % axis click
            camCont.clPatch = false;            
        end
        
        % get mouse pos on 'sphere'
        camCont.mPos1 = cam_getCurrPos(handles.brainAx,handles.brainAx.XLim(2)); 
        f_h.WindowButtonMotionFcn = @cam_mMoveFcn_rot;
        
    case 'e' % extend, pan
        
        camCont.mPos1 =   f_h.CurrentPoint;  % get mouse pos on figure
        camCont.figSize = f_h.Position(3:4); % get current figure size
        f_h.WindowButtonMotionFcn = @cam_mMoveFcn_pan;
        
    otherwise % alt, do nothing
        f_h.WindowButtonMotionFcn = '';
end

% set button up function
f_h.WindowButtonUpFcn = @cam_bUpFcn;

% update appdata
setappdata(f_h,'camCont',camCont);

end