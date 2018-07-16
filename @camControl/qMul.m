function [q3] = qMul(q1,q2)
% multiplies two quaternions
%
% (req.) q1, first quaternian, format [s,v] where v = xyz
% (req.) q2, second quaternian, format as q1
% (ret.) q3, product of q1,q2

q3 = [q1(1)*q2(1) - dot(q1(2:4),q2(2:4)),...
    q1(1)*q2(2:4) + q2(1)*q1(2:4) + cross(q1(2:4),q2(2:4))];

end