
% tried to implement A* algorithm... can't do better than matlab's dijkstra
% at the moment >< ... at the very least probably need a heap, likely not
% worth the effort!

disp('running');

nVert = length(TR.Points);

% get a list of edges
e = TR.edges;

% calculate length of each edge
eLen = vecnorm(TR.Points(e(:,1),:) - TR.Points(e(:,2),:),2,2);

% create adjacency matrix
adjMat = sparse([e(:,1); e(:,2)], [e(:,2); e(:,1)], ...
    [eLen; eLen], nVert, nVert);

%--------------------------------------------------------------------------

sV = 70618; %randi(nVert,1);
tV = 21711; %randi(nVert,1);

% create set for vertices to visit
toVis = false(nVert,1);
toVis(sV) = 1;

% create heuristic values - euclidean distance
hVals = sqrt(sum((TR.Points - TR.Points(tV,:)).^2,2));

% create records of act. distance from source (g), guessed distance to
% target from heuristic (h) and prev. vertex
gDist = inf(nVert,1);
hDist = inf(nVert,1);
vPrev = zeros(nVert,1,'uint32');

% for first note, act. distance = 0, fill in heuristic
gDist(sV) = 0;
hDist(sV) = hVals(sV);

while true
    
    % get vertex with lowest score
    [~,cV] = min(hDist);
    
    % if we're at target, break
    if cV == tV, break; end
    
    % remove current vertex from 'to visit' list
    toVis(cV) = 0;
    hDist(cV) = inf;
    
    % get the neighbours of the current vertex
    [nV,~,nVal] = find(adjMat(:,cV));
    test = find(adjMat(:,cV));
    test2 = sum((TR.Points(test,:) - TR.Points(cV,:)).^2,2);
    
    % add neighbours to toVis
    toVis(nV) = 1;
    
    % calc. alternative distance, dist from neighbours to current vertex
    altDist = gDist(cV) + nVal;
    
    % work out which neighbours to update (if any)
    toDel = altDist >= gDist(nV);
    nV(toDel) = [];
    altDist(toDel) = [];
    
    if ~isempty(nV)
        % set current point as prev. vertex for each neighbour
        vPrev(nV) = cV;
        
        % update actual distance
        gDist(nV) = altDist;
        
        % update heuristic distance
        hDist(nV) = altDist + hVals(nV);
    end
end

sPath = [tV; zeros(1e4,1)];
inc = 1;
while vPrev(sPath(inc))~= 0
    inc = inc + 1;
    sPath(inc) = vPrev(sPath(inc-1));
end
sPath = flipud(sPath(1:inc));

tic; sPath2 = shortestpath(G,sV,tV)'; toc

disp('done');





