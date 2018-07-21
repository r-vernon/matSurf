function [allVert] = ROI_fill(obj,bPts,midPt)
% function to flood fill an ROI contained within specified boundary
% Uses breadth-first based flood filling
%
% (req.) bPts, boundary points, the boundary for the ROI to fill
% (opt.) midPt, vertex ind of middle point, any point inside ROI, in case
%        need to override automatically calculated midPt
% (ret.) allVert, all vertices contained within the ROI (incl. boundary)

% if not provided, calculate the mid point of the ROI
% (used as source for filling region)
if nargin < 3 || isempty(midPt)
    midPt  = nearestNeighbor(obj.TR,mean(obj.TR.Points(bPts,:)));
end

% create index to record which points have been visited, search won't
% progress past these points
vis = false(obj.nVert,1);

% set boundary to visited, plus midPt as will be starting there so don't
% need to visit again
vis([bPts;midPt]) = true;

% keep a record of which points should be visited (at start, just source)
toVis = midPt;

% create (sparse) adjacency matrix that stores vertex neighbours
% (e.g. if adjMat(1,2) = 1, then edge exists between vert.1 and vert.2)
adjMat = adjacency(obj.G);

while ~isempty(toVis) % while there's points to be visited
    
    % get all neighbours of current point(s)
    % - find gets all the neighbours
    % - mod(x-1,nRows)+1 is like ind2sub but rows only
    % - unique does what it says on the tin...
    currN = unique(mod(find(adjMat(:,toVis))-1,obj.nVert)+1);
    
    % delete any that have already been visited
    currN(vis(currN)) = [];
    
    % mark points added to list as visited so they don't get added again
    vis(currN) = true;
    
    % update toVis with current neighbours neighbours
    toVis = currN;
    
end

% finished, now just find all the points that managed to visit
allVert = find(vis);

end