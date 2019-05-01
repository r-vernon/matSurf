function [visOrd] = dfs_implementation(adjMat,stPnt)

% get num nodes
nV = size(adjMat,1);

% create index of visited vertices, stack of vertices to visit and visit order list
vis    = zeros(nV,1,'logical');
toVis  = zeros(nV,1,'uint32');
visOrd = zeros(nV,1,'uint32');

% create indices for to visit stack and vis order list
toVis_idx  = zeros(1,'uint32');
visOrd_idx = ones(1,'uint32');

% push the start point onto stack
toVis(1) = stPnt;
toVis_idx = toVis_idx +1;

% while 'to visit' stack not empty
while toVis_idx > 0
    
    % pop current vertex off stack
    currV = toVis(toVis_idx);
    toVis_idx = toVis_idx -1;
    
    % if current vertex not previously discovered
    if ~vis(currV)
        
        % add vertex to list
        visOrd(visOrd_idx) = currV;
        visOrd_idx = visOrd_idx +1;
        
        % mark vertex as discovered
        vis(currV) = 1;
        
        % find all adjacent vertices
        adjV = find(adjMat(:,currV));
        
        % push them onto stack
        % (for loop = faster indexing)
        for ii = 1:numel(adjV)
            toVis(toVis_idx+ii) = adjV(ii);
        end
        toVis_idx = toVis_idx +numel(adjV);
    end
end

end