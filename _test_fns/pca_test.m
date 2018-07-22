
a = R3517_rh_in.TR.Points;
[coeff,score,latent,tsquared,explained,mu] = pca(a);

[~,xInd] = max(coeff(1,:));
[~,yInd] = max(coeff(2,:));
[~,zInd] = max(coeff(3,:));

tgt = [1,0,0; 0,1,0; 0,0,1]';

u = cross(coeff(:,xInd),tgt(:,1));
normU = norm(u); 
th = atan2(normU,dot(coeff(:,xInd),tgt(:,1)));
u = u/normU;  
qForm = [cos(th/2),sin(th/2)*u'];

u = cross(coeff(:,yInd),tgt(:,2));
normU = norm(u); 
th = atan2(normU,dot(coeff(:,yInd),tgt(:,2)));
u = u/normU;  
qForm = qMul([cos(th/2),sin(th/2)*u'],qForm);

u = cross(coeff(:,zInd),tgt(:,3));
normU = norm(u); 
th = atan2(normU,dot(coeff(:,zInd),tgt(:,3)));
u = u/normU;  
qForm = qMul([cos(th/2),sin(th/2)*u'],qForm);

% convert to rotation matrix to pass for rendering
qForm_R = qRotMat(qForm);

test = (a-mu)*qForm_R(1:3,1:3);