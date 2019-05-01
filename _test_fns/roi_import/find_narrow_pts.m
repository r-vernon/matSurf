
adjMat = adjacency(obj.G);
bpCons = adjMat(:,bPts)';
adjMat(bPts,:) = [];
narrowPts = find(~any(adjMat,1));

    
narrowAdj = find(bpCons(:,narrowPts));
tmp1 = intersect(narrowAdj,find(bpCons(narrowAdj(1),bPts)));