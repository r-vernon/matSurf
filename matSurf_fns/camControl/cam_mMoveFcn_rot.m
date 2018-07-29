function cam_mMoveFcn_rot(src,~)
% function to call for mouse movement

% get data
camControl = getappdata(src,'camControl');
handles = getappdata(src,'handles');

% get current panel size
pSize = handles.axisPanel.Position;
        
% get mouse pos on 'sphere' covering panel, radius 1
% see cam_bDownFcn for explanation
mPos2 = zeros(1,3);
mPos2([1,3]) = (src.CurrentPoint-pSize(1:2))./(0.5*pSize(3:4)) - 1;
currPos_SSq = sum(mPos2.^2);
if currPos_SSq <= 1, mPos2(2) = -sqrt(1-currPos_SSq); end

% get time
cTime = clock;

% make sure we've moved reasonable amount...
% (doing this before scaling so don't magnify false +ves)
if norm(mPos2-camControl.mPos1) < 0.01 || etime(cTime,camControl.tStmp) < camControl.fRate
    return;
end
camControl.mMoved = true;
camControl.tStmp  = cTime;

% wipe the stored view (if any)
camControl.view = '';

% calculate unit vector (u), and angle of rotation (theta, th)
u = cross(camControl.mPos1,mPos2);             % calc vector
normU = norm(u);                            % calc vector norm
th = atan2(normU,dot(camControl.mPos1,mPos2)); % calc theta
u = u/normU;                                % make unit vector

% scale theta by sensitivity
th = th*camControl.mSens(1);

% convert to unit quaternion and multiply by previous rotation
qForm2 = [cos(th/2),sin(th/2)*u];
qForm2 = qMul(qForm2,camControl.qForm);

% convert to rotation matrix to pass for rendering
qForm2_R = qRotMat(qForm2);

% set the rotation
handles.xForm.Matrix = qForm2_R;

% update mouse position, rotation qForm to latest values
camControl.mPos1 = mPos2;
camControl.qForm = qForm2;

% update appdata
setappdata(src,'camControl',camControl);

end