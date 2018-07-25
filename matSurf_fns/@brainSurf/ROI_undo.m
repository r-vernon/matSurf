function [vCoords,prevVal] = ROI_undo(obj)
% function to undo last ROI point
%
% (ret.) vCoords, updated ROI coordinates after point removed
% (ret.) prevVal, index of previously selected vertex
% (set.) ROIs, clears seleced/all vertices associated with removed point
% (set.) ROI_lineInd, as above 
% (set.) ROI_sPaths, shortest paths to previous point

% get current ROI index (will be last ROI as open for editing)
ind = obj.nROIs;

% find and delete last selected marker
svEndPos = nnz(obj.ROIs(ind).selVert);       % get loc. of last sel. vertex
obj.ROIs(ind).selVert(svEndPos) = 0;         % delete last sel. vertex

% get val. of prev. sel. vertex
prevVal = obj.ROIs(ind).selVert(svEndPos-1); 

% delete all vertex after last marker
avEndPos = nnz(obj.ROIs(ind).allVert);
avStPos = find(obj.ROIs(ind).allVert(1:avEndPos) == prevVal,1,'last');
obj.ROIs(ind).allVert(avStPos+1:avEndPos) = 0;

% delete all vertices in global list
lEndPos = nnz(obj.ROI_lineInd);
lStPos = lEndPos - (avEndPos - avStPos);
obj.ROI_lineInd(lStPos+1:lEndPos) = 0;

% update shortest paths with shortest paths from every point to prevVal
obj.ROI_sPaths = shortestpathtree(obj.G,prevVal,...
    'Method','positive','OutputForm','vector');

% return updated vertex coords
vertInd = obj.ROI_lineInd(1:lStPos);
vCoords = obj.ROI_get(vertInd);

end