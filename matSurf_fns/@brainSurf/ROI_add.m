function [vCoords,newROI] = ROI_add(obj,v2add)
% function to add an ROI point, sets both the selected point to be shown
% with a marker, and all (if any) intermediate points to be shown as a line
%
% (opt.) v2add,   the vertex the user clicked, or empty if closing ROI
% (ret.) vCoords, vertex coords to plot with line
% (ret.) newROI,  true if ROI is new
% (set.) ROIs,    if new ROI, details of that ROI
% (set.) nROIs,   number of ROIs

%--------------------------------------------------------------------------
% work out whether starting new ROI, or adding to current one

% starting new ROI if:
% - nROIs is 0 (then very first ROI so has to be new)
% - current ROI is finished (so no [e])

% test if new ROI
if obj.nROIs == 0 || ~contains(obj.ROIs.name{obj.currROI},'[e]')
    newROI = true;
    obj.nROIs   = obj.nROIs +1; % update num ROIs
    obj.currROI = obj.nROIs;    % set as current
else
    newROI = false;
end

% get index of ROI we're working on
ind = obj.currROI;

% if vInd empty, presume closing ROI
if nargin <2 || isempty(v2add)
    % set selected vertex to first vertex
    v2add = obj.ROIs.selVert{ind}(1); 
end

%==========================================================================
% deal with new ROIs

if newROI

    % find a safe name (adding [e] to show it's open for editing)
    inc = 1;
    if ind ~=1 && any(contains(obj.ROIs.name,'ROI_','IgnoreCase',true))
        while any(contains(obj.ROIs.name,sprintf('ROI_%03d',inc),'IgnoreCase',true))
            inc = inc + 1;
        end
    end
    obj.ROIs.name{ind,1} = sprintf('[e] %s_ROI_%03d',upper(obj.surfDet.hemi),inc);
    
    % set visibility to true
    obj.ROIs.visible(ind,1) = true; 
    
    %------------------------------------
    % set first vertex in allVert/selVert
    
    % preallocate space for all vertices (will shrink when ROI finished)
    % can additionally set first index to selected vertex
    obj.ROIs.allVert{ind,1} = [v2add; zeros(1e4,1,'single')];
    
    % make smaller copy for selected vertices
    obj.ROIs.selVert{ind,1} = obj.ROIs.allVert{ind}(1:100);
    
    % set nVert to 1
    obj.ROIs.nVert(ind,1) = 1;

    %------------
    % set vertInd

    vertInd = [v2add; nan];
    
    %======================================================================
    % deal with existing ROIs
    
else
    
    %-----------------------
    % get next pos. to write
    
    % for allVert use nVert, for selVert just count nonzeros
    allV_nxtPos = obj.ROIs.nVert(ind) +1;
    selV_nxtPos = nnz(obj.ROIs.selVert{ind}) +1;
    
    %----------------------
    % get path to new point
    
    sPath = shortestpath(obj.G,obj.ROIs.selVert{ind}(selV_nxtPos-1),v2add)';
    
    % delete first point to avoid duplication
    sPath(1) = [];
    
    % count num. points to be added
    nPts2add = numel(sPath);
    
    %-------------------------------------
    % make sure arrays can hold new points

    obj.ROIs.allVert{ind} = expandArray(obj.ROIs.allVert{ind}, 1e4, nPts2add);
    obj.ROIs.selVert{ind} = expandArray(obj.ROIs.selVert{ind}, 100, 1);
    
    %------------------------
    % write new points to ROI
    
    % calc. new allVert ending position
    allV_newEnd = allV_nxtPos + nPts2add -1;
    
    % add on all and selected vertices
    obj.ROIs.allVert{ind}(allV_nxtPos:allV_newEnd) = sPath;
    obj.ROIs.selVert{ind}(selV_nxtPos) = v2add;
    
    % update nVert
    obj.ROIs.nVert(ind) = allV_newEnd;
    
    %------------
    % set vertInd

    vertInd = [obj.ROIs.allVert{ind}(1:allV_newEnd); nan];
    
end

%--------------------------------------------------------------------------
% set return variables

% get actual vertex coords to return
vCoords = obj.ROI_get(vertInd);

end
