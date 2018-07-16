handles.ulLight.Visible = 'on';
handles.urLight.Visible = 'off';
handles.llLight.Visible = 'off';
handles.lrLight.Visible = 'off';

handles.aLights.Visible = 'off';

lStyle = 'infinite';
handles.llLight.Style = lStyle;
handles.lrLight.Style = lStyle;
handles.llLight.Style = lStyle;
handles.lrLight.Style = lStyle;

% light strength
lStrength = 0.8;
lStrength = repmat(lStrength,1,3);
handles.ulLight.Color = lStrength;
handles.urLight.Color = lStrength;
handles.llLight.Color = lStrength;
handles.lrLight.Color = lStrength;

light_d2m = tand(35) * abs(handles.brainAx.CameraPosition(2));
handles.llLight.Position = [ light_d2m, -350,  light_d2m];
handles.lrLight.Position = [-light_d2m, -350,  light_d2m];
handles.ulLight.Position = [ light_d2m, -350, -light_d2m];
handles.urLight.Position = [-light_d2m, -350, -light_d2m];

handles.brainPatch.BackFaceLighting = 'lit';
handles.brainPatch.AmbientStrength = 0.15;
handles.brainPatch.DiffuseStrength = 0.45;
handles.brainPatch.SpecularStrength = 0.1;
handles.brainPatch.SpecularExponent = 10;
handles.brainPatch.SpecularColorReflectance = 1;


