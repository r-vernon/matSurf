
% set current path
if exist('/storage/matSurf','file')
    cPath = '/storage/matSurf';
else
    cPath = '/scratch/home/r/rv519/matSurf';
end

% save handles as h, surface as vol

% % create graph
% st = edges(vol.TR);
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
% G = graph(st(:,1),st(:,2),w);

% % create global adjanceny matrix
% AM = sparse([st(:,1);st(:,2)], [st(:,2);st(:,1)],...
%     ones(length(st)*2,1), vol.nVert, vol.nVert);

% load in vol
vol = load([cPath,'/_test_fns/roi_import/vol.mat']);
vol = vol.R3517_rh_inf;

% % load in ROI
roiExp = load([cPath,'/_test_fns/roi_import/RH_testROI.mat']);
roiExp = roiExp.R3517_rh_ROIs;

% % get all and selected vertices
% allVert = roiExp.ROIs.allVert{1};
% allVert(isnan(allVert)) = [];
% selVert = roiExp.ROIs.selVert{1};

% load in label
fid = fopen([cPath,'/_test_fns/roi_import/RH_testROI.label'],'r') ;
fgets(fid);
nV = fscanf(fid,'%d\n',1);
roiLab = fscanf(fid, '%d %*f %*f %*f %*f\n',[1 nV])' +1;
fclose(fid);

clearvars st w fid nV cPath;

%{

h.brainPatch.EdgeColor = 'k';

v2mark = vol.TR.Points(14720,:);
tmpPlot = line(h.xForm,v2mark(:,1),v2mark(:,2),v2mark(:,3),...
    'Color','red','LineStyle','none','Marker','.');
%}

%%

% find all boundary points 
% (will be points that have at least one connection outside ROI, can find with xor)
toKeep = false(vol.nVert,1);
toKeep(roiLab) = true;
e = edges(vol.TR);
boundPts = intersect(e(xor(toKeep(e(:,1)),toKeep(e(:,2))),:),roiLab,'sorted');

% keep only the edges that connect boundary points
toKeep(:) = 0;
toKeep(boundPts) = true;
e(~all(toKeep(e),2),:) = [];

%%

% toKeep(:) = 0;
% toKeep(roiLab) = true;
% 
% T = vol.TR.ConnectivityList;
% 
% [ri1,ci1] = find(T==13764);
% [ri2,ci2] = find(T==13742);
% test = T(intersect(ri1,ri2),:);
% 
% T_bp = sum(toKeep(T),2);
% T = T(T_bp==2,:);
% 
% e2 = [T(:,1:2); T(:,2:3); T(:,[1,3])];
% e2(~all(toKeep(e2),2),:) = [];
% e2 = unique(sort(e2,2),'rows');
% 
% [ri,ci] = find(e2==13764);
% e2(ri,:)

%%

% get number of connections for each boundary point (aka vertex degree)
nCon = nonzeros(accumarray(e(:),1,[],[],[],1));

% extract points with only a single connection (will be added back in later)
singPnts_idx = (nCon == 1);
if any(singPnts_idx)
    
    % get the single points
    singPnts = boundPts(singPnts_idx);
    
    % get the edge rows containing single points
    spE_idx = ismember(e,singPnts);
    spE_row = any(spE_idx,2);
    
    % get the single point edges, and indices for those edges
    % (transposing so each edge is seperate column)
    spE = e(spE_row,:)';
    spE_idx = spE_idx(spE_row,:)';
    
    % store (col1) the point each singPnt connects to and (col2) the singPnt
    toAdd = [spE(~spE_idx), spE(spE_idx)];

    % delete all references to the single connected point
    e(spE_row,:) = [];
    boundPts(singPnts_idx) = [];
    nCon(singPnts_idx) = [];
    
end

% get number of bound points (bps), and mapping between bps and bp indices
nBP = numel(boundPts);
bp2bp_idx = sparse(boundPts,ones(nBP,1),1:nBP,vol.nVert,1);

% get lengths of all edges
eLen = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));

% relabel bound points in edge list so they're 1:n (just to make life easier)
e = full(bp2bp_idx(e));

% create adjacency matrix and distance matrix (storing length of all edges)
adjMat  = sparse([e(:,1);e(:,2)], [e(:,2);e(:,1)], ones(2*size(e,1),1,'logical'), nBP, nBP);
distMat = sparse([e(:,1);e(:,2)], [e(:,2);e(:,1)], [eLen; eLen], nBP, nBP);

% make a graph
g2 = graph(e(:,1),e(:,2),eLen);
figure; plot(g2,'Layout','force');

%% break boundary points into sections of continuity

% preallocate some useful stuff..
brkPnt_idx = false(nBP,1);  % index of which points are break (branching) points
vis = false(nBP,1);         % which nodes have been visited
toVis = nan;                % next point to be visited
pathRoute = zeros(2*nBP,1); % store the path route
pathRoute_idx = 1;          % index into pathSect

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

% create index into twoCon
twoCon_idx = zeros(nBP,1);
twoCon_idx(twoCon) = 1:numel(twoCon);

%--------------------------------------------------------------------------
% find the break points between sections

if numel(twoCon) == nBP % case where all points must be two connected so forms simple loop
    
    currPnt = twoCon(1); % arbitrary choice as no breaks!
    
else
    
    % get the points where only one of the adjacent points is two-connected
    % transposing so each pair of adj. points is stored in a column
    adjPts_oneCon = xor(adjPts_twoCon(:,1),adjPts_twoCon(:,2));
    brkPnts = adjPts(adjPts_oneCon,:)';
    
    % remove the two-connected adjacent point as that'll be part of continued path
    % also transpose index, see prev. comments
    brkPnts = brkPnts(~adjPts_twoCon(adjPts_oneCon,:)');
    
    % set broken points index
    brkPnt_idx(brkPnts) = 1;
    
    % set the first non-two connected point as visited
    vis(brkPnts(1)) = 1;
    pathRoute(1) = brkPnts(1);
    pathRoute_idx = pathRoute_idx +1;
    
    % take the point that connects to this break as starting point
    currPnt = twoCon(find(adjPts_oneCon,1));
end

%--------------------------------------------------------------------------
% mark starting point as visited and add to path

vis(currPnt) = 1;
pathRoute(pathRoute_idx) = currPnt;
pathRoute_idx = pathRoute_idx +1;

%% loop until visited all possible points around path

while ~isempty(toVis)
    
    if currPnt==65, break; end
    
    % check if at breakpoint (a point where multiple poss. paths exist)
    if brkPnt_idx(currPnt)
        
        % save the curr. point as start of break and first point to vis
        bpSt = currPnt;
        bpToVis = currPnt;

        % create index to store points found in breadth-first search
        haveVis_idx = false(nBP,1);
        
        % flag to mark whether reached end of breakpoint or not
        bpEnd_found = false;
        
        % do breadth first search until reach new breakpoint
        while ~isempty(bpToVis)
            
            % get all unique neighbours of curr. point(s), deleting those already visited
            % (find gets all neighbours, mod(x-1,nRows)+1 like rows only ind2sub)
            currN = unique(mod(find(adjMat(:,bpToVis))-1,nBP)+1);
            currN(vis(currN)) = [];
            
            % test if reached end breakpoint (i.e. got back to path...)
            if ~bpEnd_found, bpEnd = currN(brkPnt_idx(currN)==1);
                if numel(bpEnd)==1
                    
                    % mark bpEnd as found, so don't have to run this bit again
                    bpEnd_found = true;
                    
                    % set next two-connected point from break point as currPnt
                    currPnt = find(adjMat(:,bpEnd) & twoCon_idx);
                    
                    % set end breakpoint and its adj. twoCon pnt as visited
                    vis([bpEnd,currPnt]) = 1;
                    
                    % delete the breakpoint from curr. neighbours so don't re-visit it
                    currN(currN==bpEnd) = [];
                    
                end
            end
            
            % set new points as next to explore, marking them visited so don't backtrack
            bpToVis = currN;
            vis(currN) = true;    
            haveVis_idx(currN) = true;
        end
        
        % get all points in the break that were visited (excl. start/end)
        haveVis = find(haveVis_idx);
  
        % get all possible paths, adding on btSt and bpEnd
        %allPaths = perms(haveVis);
        %allPaths = [bpSt(ones(size(allPaths,1),1)), allPaths, bpEnd(ones(size(allPaths,1),1))];

    end
    
    % get index for current point
    currPnt_idx = twoCon_idx(currPnt);
    if currPnt_idx == 0
        % finished path
        break; 
    end
    
    % find next viable point
    nxtPnt = adjPts(currPnt_idx,:);
    nxtPnt(vis(nxtPnt)) = [];
    
    % add next point to path and set as current point
    currPnt = nxtPnt;
    vis(currPnt) = 1;
    pathRoute(pathRoute_idx) = currPnt;
    pathRoute_idx = pathRoute_idx +1;
    
end

% remove extra points
pathRoute(pathRoute_idx:end) = [];












