function [vCoords,markInd,ind,newROI] = ROI_add(obj,ptClicked,finalPt)
% function to add an ROI point, sets both the selected point to be shown
% with a marker, and all (if any) intermediate points to be shown as a line
%
% (req.) ptClicked,   the vertex the user clicked
% (opt.) finalPt,     if true, close the ROI and append with index to nan
% (ret.) vCoords,     vertex coords to plot with line (intermediate points)
% (ret.) markInd,     vertex indices to plot with marker (selected points)
% (ret.) ind,         index of ROI point added to
% (ret.) newROI,      true if ROI is new
% (set.) ROIs,        if new ROI, details of that ROI
% (set.) pROIs,       private details of obj.ROI
% (set.) roiNames,    cell array containing names of all loaded ROIs
% (set.) nROIs,       number of ROIs
% (set.) ROI_lineInd, array with vertices for all ROIs, delimited by index 
%                     to 'NaN' in ROIpts
% (set.) ROI_markInd, stores manually clicked points to mark with marker
% (set.) ROI_sPaths,  a vector allowing calculation of the shortest
%                     path between any given vertex, and selected vertex

if nargin < 3 || isempty(finalPt), finalPt = false; end

%--------------------------------------------------------------------------
% work out whether starting new ROI, or resuming old one

% get current ROI index
ind = obj.nROIs;

% starting new ROI if:
% - ind is 0 (then very first ROI so has to be new)
% - current ROI (at ind) is finished (and so has end point set)

% test if new ROI
if ind == 0 || ~isempty(obj.pROIs(ind).endPos)
    newROI = true;
else
    newROI = false;
end

%--------------------------------------------------------------------------
% get index and coord Pts of nearest vertex to the click

% use triangulation (TR) to get nearest neighbour vertex ind
if finalPt
    % if final point, set selected vertex to first vertex
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
    
    % get index to new location
    ind = ind + 1;
    
    % set name
    ROIname = sprintf('[e] ROI %d',ind); % [e] means open for editing

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
    
    %--------------------------
    % update roiNames and nROIs
    
    obj.roiNames{ind} = ROIname;
    obj.nROIs = ind;
    
    %-------------------------------------
    % make sure arrays can hold new pointsa
    
    % e.g. if obj.ROI_lineInd > 75% full, add 1e5 extra elements
    obj.ROI_lineInd = expandArray(obj.ROI_lineInd, 1e5, 1);
    obj.ROI_markInd = expandArray(obj.ROI_markInd, 1e3, 1);
    
    %---------------------
    % set vertices to draw
    
    obj.ROI_lineInd(lStPos) = vInd;   % vertices to draw lines across
    obj.ROI_markInd(mStPos) = lStPos; % vertices to draw markers on
    
    % set line end pos. to line start pos., as only added one point
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
    nPts2add = length(sPath); 
    
    %-------------------------------------
    % make sure arrays can hold new points

    obj.ROI_lineInd       = expandArray(obj.ROI_lineInd, 1e5, nPts2add);
    obj.ROI_markInd       = expandArray(obj.ROI_markInd, 1e3, 1);
    obj.ROIs(ind).allVert = expandArray(obj.ROIs(ind).allVert, 1e5, nPts2add);
    obj.ROIs(ind).selVert = expandArray(obj.ROIs(ind).selVert, 100, 1);

    %------------------------
    % write new points to ROI
    
    % calc. allVert ending position
    % -1 as e.g. stPos = 1, adding 3, [1,2,3,...], endPos is 3, not 4
    avEndPos = avStPos + nPts2add - 1;
    
    if finalPt
        % deal with all vertices (sPath to end-1 as ignoring repeated end pt)
        obj.ROIs(ind).allVert(avStPos:avEndPos-1) = sPath(1:end-1); 
        % clear any additional padding in all/selected vertices
        obj.ROIs(ind).allVert(avEndPos+1:end) = [];
        obj.ROIs(ind).selVert(svStPos:end)  = [];
    else
        % deal with all vertices
        obj.ROIs(ind).allVert(avStPos:avEndPos) = sPath; 
        % deal with selected vertex
        obj.ROIs(ind).selVert(svStPos) = vInd;           
    end
    
    %---------------------
    % set vertices to draw
    
    % calc. line ending position
    lEndPos = lStPos + nPts2add - 1;
    
    if finalPt
        % vertices to draw lines across (appending index to nan to show finished)
        obj.ROI_lineInd(lStPos:lEndPos+1) = [sPath ; obj.nVert+1];
        % set private ROI end point
        obj.pROIs(ind).endPos = lEndPos;
    else
        % vertices to draw lines across
        obj.ROI_lineInd(lStPos:lEndPos) = sPath; 
        % vertices to draw markers on
        obj.ROI_markInd(mStPos) = lEndPos;       
    end
    
    %-----------------------------
    % if final point, update names
    
    % remove edit symbol from ROI ([e])
    if finalPt
        obj.ROIs(ind).name = erase(obj.ROIs(ind).name,'[e] ');
        obj.pROIs(ind).name = obj.ROIs(ind).name;
    end
    
    % update ROI names list
    obj.roiNames{ind} = obj.ROIs(ind).name;
    
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

% get vertex indices and marker indices
if finalPt
    vInd = obj.ROI_lineInd(1:lEndPos+1);
    markInd = obj.ROI_markInd(1:mStPos-1);
else
    vInd = obj.ROI_lineInd(1:lEndPos);
    markInd = obj.ROI_markInd(1:mStPos);
end

% get actual vertex coords to return
vCoords = obj.ROIpts(vInd,:);

end
