function [q2] = qInv(q1)
% returns inverse of unit quaternian
%
% (req.) q1, quaternian to inverse, format [s,v] where v = xyz
% (ret.) q2, inverse of q1

% if q = [s,v], inv(q) = [s,-v], where v = (x,y,z)
q2 = [q1(1),-q1(2:4)];

end