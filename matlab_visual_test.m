
%% ------------------------------------------------------------------------

%set subjects directory
SUBJECTS_DIR=[pwd,'/Data/R3517'];

% make sure freesurfer on the path
if ~exist('read_surf','file')
    addpath('/usr/local/freesurfer/matlab');
end

% set colormaps and interpolation functions
x = linspace(0,1,1e5);
ret_cmap = parula(1e5); % retinotopy
ret_interp = @(xq) [interp1(x,ret_cmap(:,1),xq,'spline'),interp1(x,ret_cmap(:,2),xq,'spline'),...
    interp1(x,ret_cmap(:,3),xq,'spline')];
coher_cmap = hot(1e5); % coherence
coher_interp = @(xq) [interp1(x,coher_cmap(:,1),xq,'linear'),interp1(x,coher_cmap(:,2),xq,'linear'),...
    interp1(x,coher_cmap(:,3),xq,'linear')];

% create global variables
global fs; % freesurfer surface
global cm; % colormap
global ROI; % ROI plot

%% ------------------------------------------------------------------------
%load in all necessary files

% first the mesh itself
if ~exist('fs.vert','var')
    
    [fs.vert, fs.faces] = read_surf([SUBJECTS_DIR,'/surf/rh.inflated']);
    
    % add 1 due to FS zero indexing
    % swapping cols of faces as apparently that fixes normals
    fs.faces = fs.faces(:,[1 3 2]) + 1;
    
    % count number of vertices
    fs.nVert = size(fs.vert,1);
    
    % create triangulation
    % (nearestNeighbor(fs.TR,P) - find closes vertex to point P)
    fs.TR = triangulation(fs.faces,fs.vert);
    
    % use triangulation to created weighted (w) graph
    % (shortestpath(fs.G,s,t) - find path between vertices s and t)
    st = edges(fs.TR);
    w = sqrt(sum(bsxfun(@minus,fs.vert(st(:,1),:),fs.vert(st(:,2),:)).^2,2));
    fs.G = graph(st(:,1),st(:,2),w);
    clear st w;
end

% curvature information for the 'base' colour
if ~exist('curv','var')
    fs.curv = read_curv([SUBJECTS_DIR,'/surf/rh.curv']);
end

% retinotopy phase information (or otherwise)
if ~exist('phaseInfo','var')
    phaseInfo = MRIread([SUBJECTS_DIR,'/data/Phase_RH.nii.gz']);
    phaseInfo = phaseInfo.vol';
    
    % work out where to show retinotopy, and where to show brain
    showRet = phaseInfo ~= 0;
    
    % set retinotopy lower/upper bounds (pre-determined by analysis)
    rc_lb = 67.5; % lower bound - map to min colour
    rc_ub = 292.5; % upper bound - map to max colour
    
    % scale phaseInfo to make maximal use of colorbar
    phaseInfo = (phaseInfo - rc_lb) / (rc_ub-rc_lb); % scale to 0-1
end

% coherence information
if ~exist('coherInfo','var')
    coherInfo = MRIread([SUBJECTS_DIR,'/data/Coher_RH.nii.gz']);
    coherInfo = coherInfo.vol';
end

%% ------------------------------------------------------------------------
% create various colourmaps

% create alpha based on coherence
cm.alpha = zeros(fs.nVert,1);
cm.alpha(showRet) = normcdf(coherInfo(showRet),0.4,0.1);

% create curvature information colormap (the 'base' colour)
cm.baseCol = repmat(0.8,fs.nVert,3);
cm.baseCol(fs.curv > 0,:) = 0.4;

% create retinotopy and coherence colormaps
% first the base
cm.retCol = (1-cm.alpha).*cm.baseCol;
cm.coherCol = cm.retCol;
% then the info
cm.retCol(showRet,:) = cm.retCol(showRet,:) + ...
    (cm.alpha(showRet).*ret_interp(phaseInfo(showRet)));
cm.coherCol(showRet,:) = cm.coherCol(showRet,:) + ...
    (cm.alpha(showRet).*coher_interp(coherInfo(showRet)));

% set as overlay colormap (keeping original two around in case needed)
cm.olayCol = cm.retCol;

p.FaceVertexCData = cm.retCol;

%% ------------------------------------------------------------------------
% set the properties that will be used for drawing an ROI (plot3)
%
% 'PickableParts' particularly important, setting to 'none' means can't be
% clicked

% plotProp(1) will be markers
ROI.plotProp(1).NameArray = ...
    {'Color','LineStyle','LineWidth',...
    'MarkerFaceColor','Marker','MarkerSize',...
    'PickableParts'};
ROI.plotProp(1).ValueArray = {'black','none',1.5,'black','o',3,'none'};

% plotProp(2) will be line
ROI.plotProp(2) = ROI.plotProp(1);
ROI.plotProp(2).ValueArray{2} = '-'; % set linestyle to '-'
ROI.plotProp(2).ValueArray{5} = 'none'; % set Marker to none

% preallocate space for ROI vertices
% will store both manually picked vertices, and all (picked + intermediate)
% vertices (i.e. the path). pl_m and pl_l are empty placeholders for plots
% (marker/line)
ROI.curr(1).pl_m = gobjects;
ROI.curr(1).pl_l = gobjects;
ROI.curr(1).pVert = [];
ROI.curr(1).aVert = {};

%% ------------------------------------------------------------------------

clear p;
p = patch('vertices',fs.vert,'faces',fs.faces,...
    'FaceVertexCData',cm.olayCol,'facecolor','interp','edgecolor','none',...
    'FaceLighting','gouraud','ButtonDownFcn',@testCall);
% camlight('headlight','infinite')
% material dull;

% set axis properties
ax = gca;
set(ax,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual',...
    'PlotBoxAspectRatio',[1,1,1],'PlotBoxAspectRatioMode','manual',...
    'Visible','off');
hold(ax,'on');

% initialise camera toolbar
cameratoolbar;

% p.ButtonDownFcn = @testCall;








