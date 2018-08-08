function cam_manual_rot(f_h,rotDir)
% function to elicit manual camera movement (rotation)
%
% (req.) rotDir, rotation direction (1 up, 2 left, 3 right, 4 down)

% get data
currVol = getappdata(f_h,'currVol');
camControl = getappdata(f_h,'camControl');
handles = getappdata(f_h,'handles');

% wipe the stored view (if any)
camControl.view = '';

% set rotation angle (th) - TODO: user preference
th = 10;

% set rotation vector (u)
switch rotDir
    case 1 % up      (cross([ 0,-1, 0],[ 0,-1, 1]))
        u = [-1, 0, 0];
    case 2 % left    (cross([ 0,-1, 0],[-1,-1, 0]))
        u = [ 0, 0,-1];
    case 3 % right   (cross([ 0,-1, 0],[ 1,-1, 0]))
        u = [ 0, 0, 1];
    otherwise % down (cross([ 0,-1, 0],[ 0,-1,-1]))
        u = [ 1, 0, 0];
end

% convert to unit quaternion and multiply by previous rotation
qForm2 = [cosd(th/2),sind(th/2)*u];
qForm2 = qMul(qForm2,camControl.qForm);

% convert to rotation matrix to pass for rendering
qForm2_R = qRotMat(qForm2);

% set the rotation
handles.xForm.Matrix = qForm2_R;

% update rotation qForm to latest values
camControl.qForm = qForm2;
currVol.q_cur    = qForm2;

% update appdata
setappdata(f_h,'camControl',camControl);

end