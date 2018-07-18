function cam_bDownFcn(src,event)
% function called when patch, panel or axis button down callback triggered

% get data
f_h = getFigHandle(src);
camCont = getappdata(f_h,'camCont');
currVol = getappdata(f_h,'currVol');
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
            camCont.ip = nearestNeighbor(currVol.TR,ip(2:4));        
            
        else            
            % axis click
            camCont.clPatch = false;            
        end
        
        % get current panel size
        pSize = handles.axisPanel.Position;
        
        % get mouse pos on 'sphere' covering panel, radius 1
        % (currPnt - min(panelSz))/0.5*range(panelSz) - 1
        % if panel 0.25-1.0 and pnt 0.5, (0.5-0.25)/0.375 -1 = -1/3
        camCont.mPos1 = zeros(1,3);
        camCont.mPos1([1,3]) = (f_h.CurrentPoint-pSize(1:2))./(0.5*pSize(3:4)) - 1;
        
        % if mPos1 within circle (<=1), get depth from basic pythag., otherwise set to 0
        currPos_SSq = sum(camCont.mPos1.^2);
        if currPos_SSq <= 1, camCont.mPos1(2) = -sqrt(1-currPos_SSq); end

        f_h.WindowButtonMotionFcn = @cam_mMoveFcn_rot;
        
    case 'e' % extend, pan
        
        camCont.mPos1 =   f_h.CurrentPoint;  % get mouse pos on figure
        f_h.WindowButtonMotionFcn = @cam_mMoveFcn_pan;
        
    otherwise % alt, do nothing
        f_h.WindowButtonMotionFcn = '';
end

% set button up function
f_h.WindowButtonUpFcn = @cam_bUpFcn;

% update appdata
setappdata(f_h,'camCont',camCont);

end