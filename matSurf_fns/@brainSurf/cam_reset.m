function cam_reset(obj)
% resets current camera view to default state
%
% (set.) VA_cur, sets current value array to default value array
% (set.) q_cur,  sets current quaternion to default quaternion

obj.VA_cur = obj.cam.VA_def;
obj.q_cur  = obj.cam.q_cur;

end