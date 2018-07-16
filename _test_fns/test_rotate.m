function test_rotate

% % load in data
myData = load('/storage/matSurf/Data/test_surf.mat');
fs = myData.fs;
cm = myData.cm;
clearvars myData;

% align to centroid
centroid = [-3.3204    3.4414   -1.0031];
fs.vert = bsxfun(@minus,fs.vert,centroid);

% [x,y,z] = sphere(50); 
% x = x*135;
% y = y*135;
% z = z*135;
% [fs.faces,fs.vert,cm.olayCol] = surf2patch(x,y,z,z); 

f_h = findobj('Type','Figure','Tag','f_h');
if ~isempty(f_h)
    close(f_h);
end

%     'XColor','none','YColor','none','ZColor','none',...
%         ,'XTick',[],'YTick',[],'ZTick',[]

% Create the figure and axis
f_h = figure('Name','test','Tag','f_h','NumberTitle','off',...
    'DockControls','off','Position',[300,300,600,600]);
f_h.Units = 'normalized';
a_h = axes(f_h,'Tag','a_h',...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
    'CameraPositionMode','manual','CameraTargetMode','manual',...
    'CameraUpVectorMode','auto','CameraViewAngleMode','auto',...
    'NextPlot','add','Projection','orthographic','units','normalized',...
    'Position',[0.15,0.3,0.6,0.6]);
t_h = hgtransform('Parent',a_h);
p_h = patch(a_h,'facecolor', 'interp','edgecolor','none','PickableParts','visible',...
    'MarkerEdgeColor','none','FaceLighting','gouraud','Parent',t_h);

xyzLim = [-1,1] * ceil(max(abs(fs.vert(:)))+1);
set(a_h,'XLim',xyzLim,'YLim',xyzLim,'ZLim',xyzLim);
set(p_h,'vertices',fs.vert,'faces',fs.faces,'FaceVertexCData',cm.olayCol);

% xlabel('x'); ylabel('y'); zlabel('z');

camDist = (0.8*(xyzLim(2)-xyzLim(1)))/2 / tand(45/2);
set(a_h,'CameraPosition',[0,-camDist,0],'CameraTarget',[0,0,0],...
    'CameraUpVector',[0,0,1],'CameraViewAngle',45);

assignin('base','f_h',f_h);
assignin('base','a_h',a_h);
assignin('base','p_h',p_h);
assignin('base','t_h',t_h);
assignin('base','xyzLim',xyzLim);

% set up lighting
camlight headlight;

setappdata(f_h,'cr',[1,0,0,0]);

mSens = 1.5;

% setup callbacks
a_h.ButtonDownFcn = @ah_bdfn;
f_h.ButtonDownFcn= @(~,~) disp(f_h.CurrentPoint);
p_h.ButtonDownFcn = @(~,event) ph_bdfn(event);

    function ah_bdfn(~,~)

        % grab point clicked and convert to distance from centre
        pCl([1,3]) = a_h.CurrentPoint(1,[1,3])./[a_h.XLim(2),a_h.ZLim(2)];
        pCl_SSq = sum(pCl.^2);
        if pCl_SSq > 1
            pCl(2) = 0;
        else
            pCl(2) = -sqrt(1-pCl_SSq);
        end

        % save it
        setappdata(f_h,'pPos',pCl);
        
        % set functions
        f_h.WindowButtonMotionFcn = @fh_wbmf;
        f_h.WindowButtonUpFcn     = @fh_wbuf;
        
    end

    function ph_bdfn(event)
        
        cr  = getappdata(f_h,'cr');
        ip = [0,event.IntersectionPoint];
        ip = qMul([cr(1),-cr(2:4)],qMul(ip,cr));
        disp(ip);
        ah_bdfn;
    end
        
    function fh_wbmf(~,~)

        pPos = getappdata(f_h,'pPos');
        cr  = getappdata(f_h,'cr');
        
        % grab point moved to and convert to distance from centre
        pCl([1,3]) = a_h.CurrentPoint(1,[1,3])./[a_h.XLim(2),a_h.ZLim(2)];
        pCl_SSq = sum(pCl.^2);
        if pCl_SSq > 1
            pCl(2) = 0;
        else
            pCl(2) = -sqrt(1-pCl_SSq);
        end
        
        if norm(pCl-pPos) < 0.01, return; end
        
        % calculate theta, u
        u = cross(pPos,pCl);
        th = atan2(norm(u),dot(pPos,pCl));
        th = th*mSens;
        u = u/norm(u);
        
        % convert to unit quaternion and multiply by previous rot.
        q = [cos(th/2),sin(th/2)*u];
        cr = qMul(q,cr);

        % convert to rotation matrix to pass for rendering
        cr2_R = qRot(cr);

        % set the rotation
        t_h.Matrix = cr2_R;
        
        setappdata(f_h,'pPos',pCl);
        setappdata(f_h,'cr',cr);
        
    end

    function fh_wbuf(~,~)
        
        % reset functions
        f_h.WindowButtonMotionFcn = '';
        f_h.WindowButtonUpFcn     = '';
        
    end

    function [q3] = qMul(q1,q2)
        % multiply two quaternions
        
        q3 = [q1(1)*q2(1) - dot(q1(2:4),q2(2:4)),...
            q1(1)*q2(2:4) + q2(1)*q1(2:4) + cross(q1(2:4),q2(2:4))];   
    end

    function [qR] = qRot(q1)
        % get rotation matrix from quaternion
        % quat. format - [s, v] (where v is x,y,z)
        
        % renormalise quaternion to avoid floating point errors
        q1 = q1/norm(q1);
        
        % x,y,z at 2:4, so e.g. q2(1,1:4) will be qxqs, qxqx, qxqy, qxqz
        q2 = bsxfun(@times,q1,q1(2:4)');
        
        qR = [...
            1-2*q2(2,3)-2*q2(3,4),  2*(q2(1,3)-q2(3,1)),    2*(q2(1,4)+q2(2,1)),    0; ...
            2*(q2(1,3)+q2(3,1)),    1-2*q2(1,2)-2*q2(3,4),  2*(q2(2,4)-q2(1,1)),    0; ...
            2*(q2(1,4)-q2(2,1)),    2*(q2(2,4)+q2(1,1)),    1-2*q2(1,2)-2*q2(2,3),  0; ...
            0,                      0,                      0,                      1];

    end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
end