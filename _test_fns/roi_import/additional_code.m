
% find additional bound points that form a triangle with existing boundary points
% i.e. two vertices on boundary, one inside shape
innerPts = setdiff(roiLab,tmpBoundPts);
altBoundPts = zeros(size(innerPts));
inc = 1;
for ii = 1:numel(tmpBoundPts)
    adjV = vertexAttachments(vol.TR,tmpBoundPts(ii)); % get all vertices adjacent to current vertex
    adjF = vol.TR.ConnectivityList(adjV{1},:);        % get the corresponding faces (sets of 3 vertices)
    
    nF = ismember(adjF,innerPts); % find the vertices that are not boundary points
    nF(sum(nF,2)>1,:) = 0;        % only keep vertices (faces) where two on boundary, one not
    
    vals2add = unique(adjF(nF)); % save the vertices that aren't on the boundary, but might be...
    altBoundPts(inc:inc+numel(vals2add)-1) = vals2add; % ...then add to list
    inc = inc+numel(vals2add);
end
altBountPts = unique(altBoundPts(1:inc-1));
clearvars innerPts inc ii adjV adjF nF vals2add;


%%
% pick a vertex and run with it

prevPnt = 67;
stPnt = 66;

vis = false(nE,1);
vis([prevPnt,stPnt]) = 1;

toVis = stPnt;
prevN = stPnt;

% do breadth first search to find next two-connected point
while ~isempty(toVis)
    
    % get all neighbours of current point(s)
    % - find gets all the neighbours
    % - mod(x-1,nRows)+1 is like ind2sub but rows only
    % - unique does what it says on the tin...
    currN = unique(mod(find(adjMat(:,toVis))-1,nE)+1);
    
    % delete any that have already been visited
    currN(vis(currN)) = [];
    
    % test if back on track
    nCurrN = numel(currN);
    if numel(prevN) == 1 && numel(currN) == 1
        endPnt = prevN;
        break;
    else
        prevN = currN;
    end
    
    % mark points added to list as visited so they don't get added again
    vis(currN) = true;
    
    % update toVis with current neighbours neighbours
    toVis = currN;
    
end

vis([prevPnt,stPnt,endPnt]) = 0;
visPts = find(vis);

% deal with singular points (removing them for now)
singPt = find(nCon(visPts) == 1);
if ~isempty(singPt)
    toAdd = zeros(numel(singPt),2);
    toAdd(:,1) = mod(find(adjMat(:,visPts(singPt)))-1,nE)+1;
    toAdd(:,2) = visPts(singPt);
    visPts(singPt) = [];
end

allPaths = perms(visPts);
apSz = size(allPaths);

allPaths = [repmat(stPnt,apSz(1),1),allPaths,repmat(endPnt,apSz(1),1)];
apSz(2) = apSz(2) +2;
visPts = [stPnt; endPnt; visPts];

for ii = 1:numel(visPts)
    
    currPt = visPts(ii);
    
    [ri,ci] = find(allPaths==currPt);
    ri = [ri; ri];
    ci = [ci-1; ci+1];
    
    toDel = (ci < 1) | (ci > apSz(2));
    ri(toDel) = []; 
    ci(toDel) = [];
    idx = sub2ind(apSz,ri,ci);
    
    badPath = true(apSz);
    badPath(idx) = ismember(allPaths(idx),find(adjMat(:,currPt)));
    badPath = any(~badPath,2);
    
    allPaths(badPath,:) = [];
    apSz = size(allPaths);
    
    if apSz(1) == 1, break, end
end

% if there's more than one path left (which should never happen...) take
% the one with shortest overall distance
if apSz(1) > 1
    allDist = zeros(apSz(1),1);
    for ii = 1:apSz(1)
        allDist(ii) = sum(sqrt(sum((eCoords(allPaths(ii,2:end),:)-eCoords(allPaths(ii,1:end-1),:)).^2,2)));
    end
    [~,toKeep] = min(allDist);
    allPaths = allPaths(toKeep,:);
end

% add singular points back in
if ~isempty(singPt)
    for ii = 1:size(toAdd,1)
        idx = find(allPaths==toAdd(ii,1));
        allPaths = [allPaths(1:idx),toAdd(ii,2),allPaths(idx:end)];
    end
end
