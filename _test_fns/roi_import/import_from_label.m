
% save handles as h, surface as vol

% h.brainPatch.EdgeColor = 'k';

% % create graph
% st = edges(vol.TR);
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
% G = graph(st(:,1),st(:,2),w);

% % create global adjanceny matrix
% AM = sparse([st(:,1);st(:,2)], [st(:,2);st(:,1)],...
%     ones(length(st)*2,1), vol.nVert, vol.nVert);

% load in ROI
% roiExp = load('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/RH_testROI.mat');
roiExp = load('/storage/matSurf/_test_fns/roi_import/RH_testROI.mat');
roiExp = roiExp.R3517_rh_ROIs;

% get all and selected vertices
allVert = roiExp.ROIs.allVert{1};
allVert(isnan(allVert)) = [];
selVert = roiExp.ROIs.selVert{1};

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
[unE,e_idx,unE_idx] = unique(e);
eCoords = vol.TR.Points(unE,:);
nE = numel(unE);
unE_alt = (1:nE)';
e(:) = unE_alt(unE_idx);

% create adjacency matrix
adjMat = false(nE);
adjMat(sub2ind([nE,nE],[e(:,1);e(:,2)],[e(:,2);e(:,1)])) = 1;
nCon = sum(adjMat);

% % make a graph
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));
% g2 = graph(e(:,1),e(:,2),w);
% figure; plot(g2,'Layout','force');


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










