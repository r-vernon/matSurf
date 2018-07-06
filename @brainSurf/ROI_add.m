function [vPts,markInd,ind] = ROI_add(obj,ptClicked)

%--------------------------------------------------------------------------
% first, just get index and coord Pts of nearest vertex to the click

vInd = uint32(nearestNeighbor(obj.TR,ptClicked));

%--------------------------------------------------------------------------
% work out whether starting new ROI, or resuming old one

% get current ROI index
ind = obj.nROIs;

% starting new ROI if:
% - ind is 0 (then very first ROI so has to be new)
% - current ROI (at ind) is finished (and so has end point set)

% test if new ROI
% also set stPos - working out where to save new ROI in lists
if ind == 0
    newROI = true;
    stPos = 1;
elseif ~isempty(pROIs(ind).endPos)
    newROI = true;
    stPos = pROIs(ind).endPos + 2; 
    % e.g. if endPos = 2, [1,2,nan,0,0,...], start at 4
else
    newROI = false;
    roiPos = nnz(ROIs(ind).allVert); % nnz = number of nonzeros
    stPos = pROIs(ind).stPos + roiPos;
    % e.g. if stPos = 1, nnz = 4, [1,2,3,4,0,0,...], new stPos = 5
end

%--------------------------------------------------------------------------
% deal with new ROIs

if newROI

    % set name 
    ROIname = sprintf('[e] ROI %d',ind); % [e] means open for editing
        
    % get index to new location, updating nROIs
    ind = ind + 1;
    obj.nROIs = ind;
    
    %-------------------
    % set public details
    
    obj.ROIs(ind).name = ROIname;   % ROI name
    vRec = zeros(100,1,'uint32');   % Preallocating space for 100 vertices
    vRec(1) = vInd;                 %  (Will shrink when finished)
    obj.ROIs(ind).selVert = vRec;   % selected vertex
    obj.ROIs(ind).allVert = vRec;   % all vertices
    
    %-------------------
    % set private details
        
    obj.pROIs(ind).name = ROIname;  % copy of ROI name
    obj.pROIs(ind).ind = ind;       % index of ROI In lineInd/markInd
    obj.ROI_lineInd{end+1} = vInd;  % vertices to draw lines across
    obj.ROI_markInd{end+1} = true;  % vertices to draw markers on
    
    % update shortest paths
    obj.ROI_shortestPaths = shortestpathtree(obj.G,vInd,...
        'Method','positive','OutputForm','vector');
    
    
    
    
    
end

%--------------------------------------------------------------------------
% deal with new ROIs















%--------------------------------------------------------------------------
% set return variables

% find all vertices to draw, plus breaks (NaNs) that mark diff. ROIs
allVert = cell2mat(obj.ROI_lineInd);
ROIbreaks = isnan(allVert);

vPts = zeros(length(allVert),3);
vPts = obj.ROIpts(clInd,:);
markInd = uint32(1);

    
    
end
    