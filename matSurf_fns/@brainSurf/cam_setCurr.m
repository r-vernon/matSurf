function cam_setCurr(varargin)
% stores current camera view in cam structure
%
% (opt.) Following name value pairs to store current view:
%        CameraPosition, CameraTarget, CameraViewAngle, quat
% (set.) cam, sets VA_cur and q_cur (current view)

% set check functions
chkPT = @(x) isvector(x) && isnumeric(x) && numel(x) == 3;
chkQT = @(x) isvector(x) && isnumeric(x) && numel(x) == 4;
chkVA = @(x) isscalar(x) && isnumeric(x) && x > 0  && x <= 180;

% create parser
p = inputParser;

% set required arguments
addRequired(p,'obj');
addParameter(p,'CameraPosition',[],chkPT);
addParameter(p,'CameraTarget',[],chkPT);
addParameter(p,'CameraViewAngle',[],chkVA);
addParameter(p,'quat',[],chkQT);

% parse and get obj
parse(p,varargin);
obj = p.Results.obj;

% set any valid values into current
if ~isempty(p.Results.CameraPosition)
    obj.cam.VA_cur{1} = p.Results.CameraPosition;
end
if ~isempty(p.Results.CameraTarget)
    obj.cam.VA_cur{2} = p.Results.CameraTarget;
end
if ~isempty(p.Results.CameraViewAngle)
    obj.cam.VA_cur{3} = p.Results.CameraViewAngle;
end
if ~isempty(p.Results.quat)
    obj.cam.q_cur = p.Results.quat;
end

end