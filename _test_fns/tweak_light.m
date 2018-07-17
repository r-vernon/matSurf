handles.ulLight.Visible = 'off';
handles.urLight.Visible = 'on'; % ll
handles.llLight.Visible = 'off'; % l r
handles.lrLight.Visible = 'off';

handles.aLights.Visible = 'off';

lStyle = 'infinite';
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

handles.brainPatch.BackFaceLighting = 'lit';
handles.brainPatch.AmbientStrength = 0.3;
handles.brainPatch.DiffuseStrength = 0.45;
handles.brainPatch.SpecularStrength = 1;
handles.brainPatch.SpecularExponent = 10;
handles.brainPatch.SpecularColorReflectance = 1;


