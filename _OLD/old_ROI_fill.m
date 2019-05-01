function [allVert] = ROI_fill(obj,bPts)
% function to flood fill an ROI contained within specified boundary
% Uses breadth-first based flood filling
%
% (req.) bPts, boundary points, the boundary for the ROI to fill
% (ret.) allVert, all vertices contained within the ROI (incl. boundary)

%--------------------------------------------------------------------------
% note on algorithm used...

%{

There's probably a much smarter/faster way of doing this but...

- just 'flood filling' from an inside point with boundary already marked
  as visited can hit 'narrow' points
- imagine X was 5 vertices with top/bottom two being boundary points, no 
  way to hit inner vertex as it's only connected to already visited 
  boundary points

- instead, find point way outside boundary (hopefully!) and travel until
  you hit the boundary
- know point right before hit was outside the boundary, so can now follow
  boundary path to save all adjacent outer points
- use these outer points as limits in breadth-first search and you don't
  have the narrow problem above

- current limitations with implementation:
   1. boundary must form complete cycle
   2. can only fill a single boundary at once

%}

%--------------------------------------------------------------------------
% first get boundary adjacent points

% create (sparse) adjacency matrix that stores vertex neighbours
% (e.g. if adjMat(1,2) = 1, then edge exists between vert.1 and vert.2)
adjMat = logical(adjacency(obj.G));

% get all points adjacent to boundary
% - find gets all the neighbours
% - mod(x-1,nRows)+1 is like ind2sub but rows only
% - unique so don't return duplicates
bpAdj = unique(mod(find(adjMat(:,bPts))-1,obj.nVert)+1);

% create logical index of bp adjacent points 
% (used for faster verson of intersect shortly)
bpAdj_idx = false(obj.nVert,1);
bpAdj_idx(bpAdj) = 1; % want all adjacent points...
bpAdj_idx(bPts)  = 0; % except those that are also boundary points

%--------------------------------------------------------------------------
% find a point outside boundary

% find furthest point from centre of boundary (so unlikely to be in bound!)
boundCent = mean(obj.TR.Points(bPts,:));
[~,furthPnt] = max(sqrt(sum(bsxfun(@minus,obj.TR.Points,boundCent).^2,2)));

% do depth-first search from furthest point
df_furthPnt = dfsearch(obj.G,furthPnt);

% find the first boundary point the depth-first search hits
firstHit = find(ismember(df_furthPnt,bPts),1);

% save point right before that boundary point as starting point
% (should be outside boundary)
stPnt = df_furthPnt(firstHit -1);

%--------------------------------------------------------------------------
% now get all points immediately outside boundary

% create index of which points to visit
toVis = stPnt;

% create logical index of which points have been visited
vis = false(obj.nVert,1);
vis(stPnt) = 1;

% do search around boundary to find all outer limits
while ~isempty(toVis)
    
    % get all adjacent points to current position(s)
    % (deleting any that have already been visited)
    toVis = unique(mod(find(adjMat(:,toVis))-1,obj.nVert)+1);
    toVis(vis(toVis)) = [];
    
    % only keep vertices that are boundary point adjacent (faster intersect)
    % (this stops us travelling inside boundary at any point)
    toVis = toVis(bpAdj_idx(toVis));
    
    % mark any identified points as visited so don't backtrack
    vis(toVis) = 1;
end

% save the identified points - should completely surround boundary
outsideBP = find(vis);

%--------------------------------------------------------------------------
% finally going to repeat this process (breadth-first search) from boundary
% points, to get all points inside the ROI

% update to visit/visited indices
toVis = bPts;
vis(:) = false;
vis([outsideBP;bPts]) = 1;

% do the breadth-first search
while ~isempty(toVis)
    toVis = unique(mod(find(adjMat(:,toVis))-1,obj.nVert)+1);
    toVis(vis(toVis)) = [];
    
    vis(toVis) = 1;
end

% remove points known to be outside the boundary
vis(outsideBP) = 0;

% save the final points
allVert = find(vis);

end