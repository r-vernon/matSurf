function [roiData] = ROI_get(obj,vertInd)
% function that returns all ROI coordinates for plotting
%
% (opt.) vertInd, list of all current ROI vertices
% (ret.) roiData, Vertex coords corresponding to vertices

% get all current vertices if not provided
if nargin < 2 || isempty(vertInd)
    
    [mSt,mStInd] = max(obj.pROIs(:,2)); % find last starting pos.
    mEnd = obj.pROIs(mStInd,3);         % get end pos. of last starting pos.
    
    if mEnd == 0
        mEnd = mSt + nnz(obj.ROIs(mStInd).allVert) - 1;
    else
        mEnd = mEnd + 1;
    end
    
    vertInd = obj.ROI_lineInd(1:mEnd);
end

% find NaNs in data set
roiEnds = obj.pROIs(:,3);  % find endpoints
roiEnds(roiEnds==0) = [];  % ignore unfinished ROIs
if ~isempty(roiEnds)
    roiEnds = roiEnds + 1; % find NaNs (one after valid endpoints)
    vertInd(roiEnds) = 1;  % temporarily replace NaNs with valid ind
end

% get actual vertex coords
% putting NaN at front to ensure everything is disconnected
roiData = [nan(1,3);obj.TR.Points(vertInd,:)];

% put NaNs between each ROI
if ~isempty(roiEnds)
    roiData(roiEnds+1,:) = NaN; % +1 to account for NaN at start
end

end