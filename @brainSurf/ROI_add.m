function [vPts,markInd,ind] = ROI_add(obj,ptClicked,finalPt)
% function to add an ROI point, sets both the selected point to be shown
% with a marker, and all (if any) intermediate points to be shown as a line
%
% (req.) ptClicked,  the vertex the user clicked
% (opt.) finalPt,    if true, close the ROI and append with nan
% (ret.) vPts,       vertex points to plot with line (intermediate points)
% (ret.) markInd,    vertex points to plot with marker (selected points)
% (ret.) ind,        index of ROI point added to
% (set.) ROIs,       if new ROI, details of that ROI
% (set.) pROIs,      private details of obj.ROI
% (set.) ROI_sPaths, a vector allowing calculation of the shortest
%                    path between any given vertex, and selected vertex

if nargin < 3 || isempty(finalPt), finalPt = false; end

%--------------------------------------------------------------------------
% work out whether starting new ROI, or resuming old one

% get current ROI index
ind = obj.nROIs;

% starting new ROI if:
% - ind is 0 (then very first ROI so has to be new)
% - current ROI (at ind) is finished (and so has end point set)

% test if new ROI
if ind == 0 || ~isempty(pROIs(ind).endPos)
    newROI = true;
else
    newROI = false;
end

%--------------------------------------------------------------------------
% get index and coord Pts of nearest vertex to the click and test if we
% need to expand line or marker arrays

% use triangulation (TR) to get nearest neighbour vertex ind
if finalPt
    vInd = obj.ROIs(ind).selVert(1);
else
    vInd = single(nearestNeighbor(obj.TR,ptClicked));
end

% get start positions for new vertices in line and marker indices
% (nnz = number of non zeros)
lStPos = nnz(obj.ROI_lineInd) + 1;
mStPos = nnz(obj.ROI_markInd) + 1;

%==========================================================================
% deal with new ROIs

if newROI
    
    % set name
    ROIname = sprintf('[e] ROI %d',ind); % [e] means open for editing
    
    % get index to new location, updating nROIs
    ind = ind + 1;
    obj.nROIs = ind;
    
    % preallocate space for all/selected vertices
    % (will shrink when ROI finished)
    allV = zeros(1e5,1,'single');
    allV(1) = vInd;
    selV = zeros(100,1,'single');
    selV(1) = vInd;

    %-------------------
    % set public details
    
    obj.ROIs(ind).name = ROIname; % ROI name
    obj.ROIs(ind).allVert = allV; % all vertices
    obj.ROIs(ind).selVert = selV; % selected vertex
    obj.ROIs(ind).visible = true; % visibility
    
    %--------------------
    % set private details
    
    obj.pROIs(ind).name = ROIname;  % copy of ROI name
    obj.pROIs(ind).stPos = lStPos;  % where ROI starts in line ind
    
     %-------------------------------------
    % make sure arrays can hold new pointsa
    
    % e.g. if obj.ROI_lineInd > 75% full, add 1e5 extra elements
    obj.ROI_lineInd = expandArray(obj.ROI_lineInd, 1e5, 1);
    obj.ROI_markInd = expandArray(obj.ROI_markInd, 1e3, 1);
    
    %---------------------
    % set vertices to draw
    
    obj.ROI_lineInd(lStPos) = vInd;   % vertices to draw lines across
    obj.ROI_markInd(mStPos) = lStPos; % vertices to draw markers on
    
    % set lEndPos to lStPos, as only added one point
    lEndPos = lStPos;
    
    %======================================================================
    % deal with existing ROIs
    
else
    
    %-----------------------
    % get starting positions
    
    % find starting position for all/selected vertices
    avStPos = nnz(obj.ROIs(ind).allVert) + 1;
    svStPos = nnz(obj.ROIs(ind).selVert) + 1;

    %----------------------
    % get path to new point
    
    inc = 1e4; % no single path should be > 10,000 elements!
    sPath = zeros(inc,1,'uint32');
    sPath(inc) = vInd;
    while obj.ROI_sPaths(sPath(inc))~= 0
        inc = inc - 1;
        sPath(inc) = obj.ROI_sPaths(sPath(inc+1));
    end
    
    % sPath will contain path from prev. selected point at inc, to current
    % selected point at end, so take inc+1 to end
    sPath = sPath(inc+1:end);

    % count num. points to be added
    nPtsAdded = length(sPath); 
    
    %-------------------------------------
    % make sure arrays can hold new points

    obj.ROI_lineInd       = expandArray(obj.ROI_lineInd, 1e5, nPtsAdded);
    obj.ROI_markInd       = expandArray(obj.ROI_markInd, 1e3, 1);
    obj.ROIs(ind).allVert = expandArray(obj.ROIs(ind).allVert, 1e5, nPtsAdded);
    obj.ROIs(ind).selVert = expandArray(obj.ROIs(ind).selVert, 100, 1);

    %------------------------
    % write new points to ROI
    
    % calc. allVert ending position
    avEndPos = avStPos + nPtsAdded;
    
    if finalPt
        % deal with all vertices (avEndPos minus 1 as ignoring rpt. end pt)
        obj.ROIs(ind).allVert(avStPos:avEndPos-1) = sPath(1:end-1); 
        obj.ROIs(ind).allVert(avEndPos:end) = [];
        % deal with selected vertices
        obj.ROIs(ind).selVert(svStPos:end) = [];
    else
        % deal with all vertices
        obj.ROIs(ind).allVert(avStPos:avEndPos) = sPath; 
        % deal with selected vertex
        obj.ROIs(ind).selVert(svStPos) = vInd;           
    end
    
    %---------------------
    % set vertices to draw
    
    % calc. line ending position
    lEndPos = lStPos + nPtsAdded;
    
    if finalPt
        % vertices to draw lines across (appending nan to show finished)
        obj.ROI_lineInd(lStPos:lEndPos+1) = [sPath ; nan];
        % set private ROI end point
        obj.pROIs(ind).endPos = lEndPos;
    else
        % vertices to draw lines across
        obj.ROI_lineInd(lStPos:lEndPos) = sPath; 
        % vertices to draw markers on
        obj.ROI_markInd(mStPos) = lEndPos;       
    end
end

%--------------------------------------------------------------------------
% update shortest paths

% will contain shortest paths from every point to current point
% calculate now in 'dead time' before user clicks another point
if ~finalPt
    obj.ROI_sPaths = shortestpathtree(obj.G,vInd,...
        'Method','positive','OutputForm','vector');
end

%--------------------------------------------------------------------------
% set return variables

if finalPt
    vPts = obj.ROI_lineInd(1:lEndPos+1);
    markInd = obj.ROI_markInd(1:mStPos-1);
else
    vPts = obj.ROI_lineInd(1:lEndPos);
    markInd = obj.ROI_markInd(1:mStPos);
end

end
