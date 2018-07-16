function setDefState(obj)
% stores current state as default state of camera position
%
% (set.) initCamPos, initial camera position
% (set.) initCamVA,  initial camera view angle

obj.initCamPos = obj.a_h.CameraPosition;
obj.initCamVA =  obj.a_h.CameraViewAngle;

end