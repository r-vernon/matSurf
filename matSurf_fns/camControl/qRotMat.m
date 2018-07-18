function [qR] = qRotMat(q1)
% get rotation matrix from quaternion
% quat. format - [s, v] (where v is x,y,z)
%
% (req.) q1, quaternion to generate rotation matrix from
% (ret.) qR, 4x4 rotation matrix

% renormalise quaternion
% (to avoid accumulation of floating point errors)
q1 = q1/norm(q1);

% x,y,z at 2:4, so e.g. q2(1,1:4) will be qxqs, qxqx, qxqy, qxqz
q2 = bsxfun(@times,q1,q1(2:4)');

qR = [...
    1-2*q2(2,3)-2*q2(3,4),  2*(q2(1,3)-q2(3,1)),    2*(q2(1,4)+q2(2,1)),    0; ...
    2*(q2(1,3)+q2(3,1)),    1-2*q2(1,2)-2*q2(3,4),  2*(q2(2,4)-q2(1,1)),    0; ...
    2*(q2(1,4)-q2(2,1)),    2*(q2(2,4)+q2(1,1)),    1-2*q2(1,2)-2*q2(2,3),  0; ...
    0,                      0,                      0,                      1];

end