function [f_h] = matSurf()

% TODO - make it so matSurf can take in brainSurf class as input, then can
% interact with volume programtically and call update functions to update
% GUI

% =========================================================================

% set all paths and make sure freesurfer is available
[baseDir,~,~] = fileparts(mfilename('fullpath'));
matSurf_pathSetup(baseDir);

% create the figure and associated handles
f_h = mS_create_fig(0);

% initialise the colormaps
setappdata(f_h,'cmaps',cmaps);

% initialise a volStore class, this will store handles to all surface vols
% loaded, so can swap between them
setappdata(f_h,'allVol',mS_volStore);

% create camera control structure
%{
view    - if a saved view is loaded, this stores name (wiped upon rotation)
mSens   - mouse sensitivity for (order): rotation, panning, zooming
mMoved  - true if mouse moved
mPos1   - mouse position at click (wrt. axis (normal Cl.) or fig (extend Cl.)
mState  - normal (LClick), extend (L+R Click, ScrWh Click), alt (RClick)
clPatch - true if click came from patch
ip      - intersection point between click/patch if clicked patch
qForm   - rotation matrix in quaternion form
zFact   - zoom factor, ratio of base view angle 10deg.
tStmp   - time stamp of button down
fRate   - frame rate limit of camera
%}
camControl = struct(...
    'view','','mSens',[1.5,1.0,1.5],'mState','','mPos1',[],'mMoved',false,...
    'clPatch',false,'ip',[],'qForm',[],'zFact',1,'tStmp',clock,'fRate',1/60);
setappdata(f_h,'camControl',camControl);

% set marker size preferences (length, radius)
setappdata(f_h,'markSize',[5,1]);

% set SUBJECTS_DIR
setappdata(f_h,'SUBJECTS_DIR',[pwd,'/Data']);

% show the figure
f_h.Visible = 'on';

% make sure everything is fully drawn (adding pause due to: 
% http://undocumentedmatlab.com/blog/solving-a-matlab-hang-problem)
drawnow; pause(0.05);

end
