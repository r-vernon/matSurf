function cam_mMoveFcn_rot(src,~)
% function to call for mouse movement

% get data
camCont = getappdata(src,'camCont');
handles = getappdata(src,'handles');

% get new position and time
mPos2 = cam_getCurrPos(handles.brainAx,handles.brainAx.XLim(2));
cTime = clock;

% make sure we've moved reasonable amount...
% (doing this before scaling so don't magnify false +ves)
if norm(mPos2-camCont.mPos1) < 0.01 || etime(cTime,camCont.tStmp) < camCont.fRate
    return;
end
camCont.mMoved = true;
camCont.tStmp = cTime;

% calculate unit vector (u), and angle of rotation (theta, th)
u = cross(camCont.mPos1,mPos2);             % calc vector
normU = norm(u);                            % calc vector norm
th = atan2(normU,dot(camCont.mPos1,mPos2)); % calc theta
u = u/normU;                                % make unit vector

% scale theta by sensitivity
th = th*camCont.mSens(1);

% convert to unit quaternion and multiply by previous rotation
qForm2 = [cos(th/2),sin(th/2)*u];
qForm2 = qMul(qForm2,camCont.qForm);

% convert to rotation matrix to pass for rendering
qForm2_R = qRotMat(qForm2);

% set the rotation
handles.xForm.Matrix = qForm2_R;

% update mouse position, rotation qForm to latest values
camCont.mPos1 = mPos2;
camCont.qForm = qForm2;

% update appdata
setappdata(src,'camCont',camCont);

end