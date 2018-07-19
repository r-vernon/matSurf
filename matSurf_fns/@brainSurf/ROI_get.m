function [roiData] = ROI_get(obj,vertInd)
% function that returns all ROI coordinates for plotting
%
% (opt.) vertInd, list of all current ROI vertices
% (ret.) roiData, Vertex coords corresponding to vertices

% get all current vertices if not provided
if nargin < 2 || isempty(vertInd)
    [mSt,mStInd] = max([obj.pROIs(:).stPos]);
    mEnd = obj.pROIs(mStInd).endPos;
    if isempty(mEnd)
        mEnd = mSt + nnz(obj.ROIs(ind).allVert) - 1;
    else
        mEnd = mEnd + 1;
    end
    vertInd = obj.ROI_lineInd(1:mEnd);
end

% get actual vertex coords to return
roiEnds = [obj.pROIs(:).endPos] + 1; % find NaNs
vertInd(roiEnds) = 1;                % temporarily replace NaNs with valid ind
roiData = obj.TR.Points(vertInd,:);  % grab vertex coords
roiData(roiEnds,:) = NaN;            % put NaNs back in

end