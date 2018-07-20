function [vCoords,ind,newROI] = ROI_add(obj,vInd)
% function to add an ROI point, sets both the selected point to be shown
% with a marker, and all (if any) intermediate points to be shown as a line
%
% (req.) vInd,        the vertex the user clicked, or empty if final point
% (ret.) vCoords,     vertex coords to plot with line (intermediate points)
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

%--------------------------------------------------------------------------
% work out whether starting new ROI, or resuming old one

% get current ROI index
ind = obj.nROIs;

% starting new ROI if:
% - ind is 0 (then very first ROI so has to be new)
% - current ROI (at ind) is finished (and so has end point set)

% test if new ROI
if ind == 0 || obj.pROIs(ind,3) ~= 0
    newROI = true;
else
    newROI = false;
end

%--------------------------------------------------------------------------
% get index and coord Pts of nearest vertex to the click

if isempty(vInd)
    finalPt = true;
    vInd = obj.ROIs(ind).selVert(1); % set selected vertex to first vertex
else
    finalPt = false;
end

% get start positions for new vertices in line indices
if ind == 0
    lStPos = 1;
elseif newROI
    lStPos = obj.pROIs(ind,3) + 2; % plus 2 as 'jumping' over NaN
else
    lStPos = nnz(obj.ROI_lineInd) + 1; % just count non-zeros
end

%==========================================================================
% deal with new ROIs

if newROI
    
    % get index to new location
    ind = ind + 1;
    
    % make sure space in private ROI array for new ROI
    obj.pROIs = expandArray(obj.pROIs, 10, 1);
    
    % set name
    a = {'ROI 001','ROI 002','ROI 003','test','ROI 099'};
    b = regexp(a,'^ROI ([0-9]{3})$','tokens');
    
    ROIname = sprintf('[e] ROI %03d',ind); % [e] means open for editing

    % preallocate space for all/selected vertices (will shrink when ROI finished)
    allV = zeros(1e5,1);
    selV = zeros(100,1);
    
    % set first index in both to selected vertex
    allV(1) = vInd;
    selV(1) = vInd;

    %----------------
    % set ROI details
    
    % set public details
    obj.ROIs(ind).name = ROIname; % ROI name
    obj.ROIs(ind).allVert = allV; % all vertices
    obj.ROIs(ind).selVert = selV; % selected vertex
    obj.ROIs(ind).visible = true; % visibility
    
    % set private details
    obj.pROIs(ind,1) = ind;    % ROI index (same as pos. now but not if reshuffle)
    obj.pROIs(ind,2) = lStPos; % where ROI starts in line ind
    
    %--------------------------
    % update roiNames and nROIs
    
    obj.roiNames{ind} = ROIname;
    obj.nROIs = ind;
    
    %-----------------------------------------
    % make sure line array can hold new points
    
    % e.g. if obj.ROI_lineInd > 75% full, add 1e5 extra elements
    obj.ROI_lineInd = expandArray(obj.ROI_lineInd, 1e5, 1);
    
    %---------------------
    % set vertices to draw
    
    obj.ROI_lineInd(lStPos) = vInd;   % vertices to draw lines across
    
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
    
    sPath = zeros(1e4,1); % no path should be > 1e4 pts! (won't crash if is though)
    inc = 1; 
    sPath(inc) = vInd;
    while obj.ROI_sPaths(sPath(inc))~= 0
        inc = inc + 1;
        sPath(inc) = obj.ROI_sPaths(sPath(inc-1));
    end
    
    % sPath will contain path from selected point at 1, to previously
    % selected point at inc, so take 1:inc-1 to avoid duplicated point,
    % then flip so going from prev. point to selected
    sPath = flipud(sPath(1:inc-1));

    % count num. points to be added
    nPts2add = length(sPath); 
    
    %-------------------------------------
    % make sure arrays can hold new points

    obj.ROI_lineInd       = expandArray(obj.ROI_lineInd, 1e5, nPts2add);
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
        obj.ROIs(ind).allVert(avEndPos:end) = [];
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
        % vertices to draw lines across (appending nan to show finished)
        obj.ROI_lineInd(lStPos:lEndPos+1) = [sPath ; NaN];
        % set private ROI end point
        obj.pROIs(ind,3) = lEndPos;
    else
        % vertices to draw lines across
        obj.ROI_lineInd(lStPos:lEndPos) = sPath;   
    end
    
    %-----------------------------
    % if final point, update names
    
    % remove edit symbol from ROI ([e])
    if finalPt
        obj.ROIs(ind).name = erase(obj.ROIs(ind).name,'[e] ');
        obj.roiNames{ind} = obj.ROIs(ind).name;
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

% get vertex indices
if finalPt
    vertInd = obj.ROI_lineInd(1:lEndPos+1);
else
    vertInd = obj.ROI_lineInd(1:lEndPos);
end

% get actual vertex coords to return
vCoords = obj.ROI_get(vertInd);

end
