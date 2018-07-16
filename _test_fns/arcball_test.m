
%% 
[x,y,z] = sphere(50);
h = figure(1);
a = axes;
s = surf(x,y,z);
axis square
axis([-1 1 -1 1 -1 1]);
axis off;
view(2);

s.ButtonDownFcn = @(~,event) disp(event.IntersectionPoint);
a.CameraViewAngleMode = 'manual';

%% 

p1 = [0.3440    0.0152    0.9381];
p2 = [-0.3451    0.0436    0.9371];

th = acos((dot(p1,p2)/(norm(p1)*norm(p2))));
u = cross(p1,p2);

sTh = sin(th);
cTh = cos(th);
R = [u(1)^2+(1-u(1)^2)*cTh, u(1)*u(2)*(1-cTh)-u(3)*sTh, u(1)*u(3)*(1-cTh)+(u(2))*sTh;...
    u(2)*u(1)*(1-cTh)+u(3)*sTh, u(2)^2+(1-u(2)^2)*cTh, u(2)*u(3)*(1-cTh)-(u(1))*sTh;...
    u(3)*u(1)*(1-cTh)-u(2)*sTh, u(3)*u(2)*(1-cTh)+(u(1))*sTh, u(3)^2+(1-u(3)^2)*cTh];

%%

a.CameraPosition = a.CameraPosition/R