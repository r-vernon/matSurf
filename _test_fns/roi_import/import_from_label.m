
% save handles as h, surface as vol

% h.brainPatch.EdgeColor = 'k';

% % create graph
% st = edges(vol.TR);
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
% G = graph(st(:,1),st(:,2),w);

% % create global adjanceny matrix
% AM = sparse([st(:,1);st(:,2)], [st(:,2);st(:,1)],...
%     ones(length(st)*2,1), vol.nVert, vol.nVert);

% load in vol
% vol = load('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/vol.mat');
vol = load('/storage/matSurf/_test_fns/roi_import/vol.mat');
vol = vol.R3517_rh_inf;

% % load in ROI
% % roiExp = load('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/RH_testROI.mat');
% roiExp = load('/storage/matSurf/_test_fns/roi_import/RH_testROI.mat');
% roiExp = roiExp.R3517_rh_ROIs;
% 
% % get all and selected vertices
% allVert = roiExp.ROIs.allVert{1};
% allVert(isnan(allVert)) = [];
% selVert = roiExp.ROIs.selVert{1};

% load in label
% fid = fopen('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/RH_testROI.label','r') ;
fid = fopen('/storage/matSurf/_test_fns/roi_import/RH_testROI.label','r') ;
fgets(fid);
nV = fscanf(fid,'%d\n',1);
roiLab = fscanf(fid, '%d %*f %*f %*f %*f\n',[1 nV])' +1;
fclose(fid);

clearvars st w fid nV;

%%

% find all boundary points (will be points that have at least one
% connection outside ROI, can find with xor)
toKeep = false(vol.nVert,1);
toKeep(roiLab) = true;
e = edges(vol.TR);
tmpBoundPts = intersect(e(xor(toKeep(e(:,1)),toKeep(e(:,2))),:),roiLab);

% get only edges connecting boundary points
toKeep(:) = 0;
toKeep(tmpBoundPts) = true;
e(~all(toKeep(e),2),:) = [];

% grab the weights for each edge
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));

% relabel vertices so they're 1:n just to make life easier
[unE,~,unE_idx] = unique(e);
eCoords = vol.TR.Points(unE,:);
nE = numel(unE);
e(:) = unE_idx;

% create adjacency matrix and number of connections for each vertex
adjMat = false(nE);
adjMat(sub2ind([nE,nE],[e(:,1);e(:,2)],[e(:,2);e(:,1)])) = 1;
nCon = sum(adjMat)';

%%

% make a graph
w = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));
g2 = graph(e(:,1),e(:,2),w);
figure; plot(g2,'Layout','force');

clearvars w;

%% break boundary points into sections of continuity

% preallocate some useful stuff..
bp_idx = false(nE,1);     % index of which points are break (branching) points
vis = false(nE,1);        % which nodes have been visited
toVis = nan;              % next point to be visited
pathSect = zeros(2*nE,1); % store the path sections
ps_idx = 1;               % index into pathSect

%--------------------------------------------------------------------------

% find all points that are two-connected
twoCon = find(nCon==2);

% find the adjacent points for each of the two connected points
[adjPts,~] = find(adjMat(:,twoCon));
adjPts = reshape(adjPts,2,[])';

% find the adjacent points that are also two connected
adjPts_twoCon = nCon(adjPts)==2;

% delete points where neither of the adjacent points is two connected
toDel = ~any(adjPts_twoCon,2);
twoCon(toDel) = [];
adjPts(toDel,:) = [];
adjPts_twoCon(toDel,:) = [];
clearvars toDel;

% create index into twoCon
tc_idx = zeros(nE,1);
tc_idx(twoCon) = 1:numel(twoCon);

%--------------------------------------------------------------------------
% find the break points between sections

if numel(twoCon)==nE % case where all points must be two connected so forms simple loop
    
    currPnt = twoCon(1); % arbitrary choice as no breaks!
    
else
    
    % get the points where only one of the adjacent points is two-connected
    % temp transposing so ends up reading across rows when index shortly
    adjPts_oneCon = xor(adjPts_twoCon(:,1),adjPts_twoCon(:,2));
    brkPnts = adjPts(adjPts_oneCon,:)';
    
    % remove the two-connected adjacent point as that'll be part of continued path
    % also transpose index, see prev. comments
    brkPnts = brkPnts(~adjPts_twoCon(adjPts_oneCon,:)');
    
    % set broken points index
    bp_idx(brkPnts) = 1;
    
    % set the first non-two connected point as visited
    vis(brkPnts(1)) = 1;
    pathSect(1) = brkPnts(1);
    ps_idx = ps_idx +1;
    
    % take the point that connects to this break as starting point
    currPnt = twoCon(find(adjPts_oneCon,1));
end

%--------------------------------------------------------------------------
% mark starting point as visited and add to path

vis(currPnt) = 1;
pathSect(ps_idx) = currPnt;
ps_idx = ps_idx +1;

%--------------------------------------------------------------------------

% loop until visited all possible points
while ~isempty(toVis)
    
    % check if at breakpoint, if we are, do breadth first search until reach new breakpoint
    if bp_idx(currPnt)
        
        % mark that we've found breakpoint with nan
        pathSect(ps_idx) = nan;
        ps_idx = ps_idx +1;
    
        % save out vis and toVis as copies so don't backtrack
        tmpVis = vis;
        tmptoVis = currPnt;
        
        while ~isempty(tmptoVis)
            
            % get all neighbours of current point(s)
            % (deleting any that have already been visited)
            % - find gets all the neighbours
            % - mod(x-1,nRows)+1 is like ind2sub but rows only
            % - unique does what it says on the tin...
            currN = unique(mod(find(adjMat(:,tmptoVis))-1,nE)+1);
            currN(tmpVis(currN)) = []; 
            
            % test if found a breakpoint
            nxt_bp = currN(bp_idx(currN)==1);
            if ~isempty(nxt_bp)
                
                % get the next two-connected point from break point
                currPnt = find(adjMat(:,nxt_bp)&tc_idx);
                
                % set all to visited and move on
                vis([nxt_bp,currPnt]) = 1;
                pathSect(ps_idx:ps_idx+1) = [nxt_bp,currPnt];
                ps_idx = ps_idx +2;
                break;
                
            else
                % mark points added to list as visited so they don't get added again
                % then update toVis with current neighbours neighbours
                tmpVis(currN) = true;
                tmptoVis = currN;
            end
        end
    end

    % get index for current point
    cp_idx = tc_idx(currPnt);
    if cp_idx == 0
        % finished path
        break; 
    end
    
    % find next viable point
    nxtPnt = adjPts(cp_idx,:);
    nxtPnt(vis(nxtPnt)) = [];
    
    % add next point to path and set as current point
    currPnt = nxtPnt;
    vis(currPnt) = 1;
    pathSect(ps_idx) = currPnt;
    ps_idx = ps_idx +1;
    
end

% remove extra points
pathSect(ps_idx:end) = [];


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










