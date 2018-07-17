handles.ulLight.Visible = 'off';
handles.urLight.Visible = 'off'; % ll
handles.llLight.Visible = 'off'; % l r
handles.lrLight.Visible = 'off';
drawnow;

handles.urLight.Visible = 'on';
drawnow;

handles.aLights.Visible = 'off';

lStyle = 'local';
handles.llLight.Style = lStyle;
handles.lrLight.Style = lStyle;
handles.llLight.Style = lStyle;
handles.lrLight.Style = lStyle;

% light strength
lStrength = 1;
lStrength = repmat(lStrength,1,3);
handles.ulLight.Color = lStrength;
handles.urLight.Color = lStrength;
handles.llLight.Color = lStrength;
handles.lrLight.Color = lStrength;

light_d2m = tand(45) * abs(handles.brainAx.CameraPosition(2));
light_d2m = 0.5;
handles.llLight.Position = [ light_d2m, -1,  light_d2m];
handles.lrLight.Position = [-light_d2m, -1  light_d2m];
handles.ulLight.Position = [ light_d2m, -1, -light_d2m];
handles.urLight.Position = [-light_d2m, -1, -light_d2m];

% grab general move up and to right
% nPt = makehgtform('axisrotate',[1,0,1],pi/6) * [0;handles.brainAx.YLim(1);0;1];

nPt = [70,-210,70];
handles.llLight.Position = [-nPt(1), nPt(2),-nPt(3)];
handles.ulLight.Position = [-nPt(1), nPt(2), nPt(3)];
handles.lrLight.Position = [ nPt(1), nPt(2),-nPt(3)];
handles.urLight.Position = [ nPt(1), nPt(2), nPt(3)];


handles.brainPatch.BackFaceLighting = 'lit';
handles.brainPatch.AmbientStrength = 0.6;
handles.brainPatch.DiffuseStrength = 0.15;
handles.brainPatch.SpecularStrength = 0.1;
handles.brainPatch.SpecularExponent = 50;
handles.brainPatch.SpecularColorReflectance = 1;

handles.urLight.Position = handles.brainAx.CameraPosition;
lightangle(handles.urLight,-30,-30);


P1 = handles.brainAx.CameraPosition;
P2 = handles.urLight.Position;
a = rad2deg(atan2(norm(cross(P1,P2)),dot(P1,P2)));

set(allchild(handles.aLights),'Visible','on');