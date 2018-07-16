
p1 = [0.6837   -0.0091    0.7297];
p2 = [0.2128    0.6565    0.7237];

th = acos(min([1,dot(p1,p2)/(norm(p1)*norm(p2))]));
u = cross(p1,p2);
u = u/norm(u);
tr = makehgtform('axisrotate',u,th);

%-----------------------

% define some quaternion operations
qmul = @(q1,q2) [q1(1)*q2(1) - dot(q1(2:4),q2(2:4)),...
    q1(1)*q2(2:4) + q2(1)*q1(2:4) + cross(q1(2:4),q2(2:4))];

qconj = @(q) [q(1),-q(2:4)];
qnorm = @(q) sqrt(sum(q.^2));
qinv =  @(q) qconj(q)/(qnorm(q)^2);

qR = @(q) [...
    1-(2*q(3)^2)-2*q(4)^2,   2*(q(2)*q(3)-q(4)*q(1)), 2*(q(2)*q(4)+q(3)*q(1)), 0;...
    2*(q(2)*q(3)+q(4)*q(1)), 1-(2*q(2)^2)-2*q(4)^2,   2*(q(3)*q(4)-q(2)*q(1)), 0;...
    2*(q(2)*q(4)-q(3)*q(1)), 2*(q(3)*q(4)+q(2)*q(1)), 1-(2*q(2)^2)-2*q(3)^2,   0;...
    0,                       0,                       0,                       1];

    q1 = [0,p1];
q2 = [cos(th/2),sin(th/2)*u];

q3 = qmul(q2,qmul(q1,qinv(q2)));