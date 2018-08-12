function [vCoords,prevVal] = ROI_undo(obj)
% function to undo last ROI point
%
% (ret.) vCoords, updated ROI coordinates after point removed
% (ret.) prevVal, index of previously selected vertex
% (set.) ROIs, clears seleced/all vertices associated with removed point
% (set.) ROI_lineInd, as above 

% get current ROI index
ind = obj.currROI;

% find and delete last selected marker
selV_end = nnz(obj.ROIs.selVert{ind}); % get loc. of last sel. vertex 
obj.ROIs.selVert{ind}(selV_end) = 0;   % delete last sel. vertex

% get val. of prev. sel. vertex
prevVal = obj.ROIs.selVert{ind}(selV_end-1); 

% delete all vertex after last marker
allV_end = obj.ROIs.nVert(ind);
allV_newEnd = find(obj.ROIs.allVert{ind}(1:allV_end) == prevVal,1,'last');
obj.ROIs.allVert{ind}(allV_newEnd+1:allV_end) = 0;
obj.ROIs.nVert(ind) = allV_newEnd;

% return updated vertex coords
vertInd = [obj.ROIs.allVert{ind}(1:allV_newEnd); nan];
vCoords = obj.ROI_get(vertInd);

end