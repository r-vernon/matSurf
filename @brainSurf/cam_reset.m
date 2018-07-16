function cam_reset(obj)
% resets camera to default state
%
% (set.) cam, sets VA_cur to VA_def, and q_cur to q_def

obj.cam.VA_cur = obj.cam.VA_def;
obj.cam.q_cur  = obj.cam.q_cur;

end