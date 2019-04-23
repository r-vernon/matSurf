
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