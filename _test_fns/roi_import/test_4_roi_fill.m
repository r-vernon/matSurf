
%--------------------------------------------------------------------------
% first, make sure boundary points are in counterclockwise winding order

% do dfsearch from midPt, get first boundary point and preceeding point
% (point reached just before boundary, i.e. inside boundary)
dfs = dfsearch(obj.G,midPt);
firstBP = find(ismember(dfs,bPts),1);
firstBP = dfs([firstBP-1;firstBP]);

% get any triangle which includes two bundary points, and preceeding point
targTri = find(bPts==firstBP(2),1);
if targTri == numel(bPts) % if at end, take prev. visited point
    targTri = [bPts([targTri-1,targTri]);firstBP(1)];
else
    targTri = [bPts([targTri,targTri+1]);firstBP(1)];
end

% get the indices of that triangle in the connectivity list
targTri_idx = vertexAttachments(obj.TR,double(targTri));
targTri_idx = intersect(intersect(targTri_idx{1},targTri_idx{2}),targTri_idx{3});

% get face normal and coords of tri
targTri_norm = faceNormal(obj.TR,targTri_idx);
targTri_co = obj.TR.Points(targTri,:);

% calculate cross product and take sign of dot prod. with normal
% (-1 if wrong direction, 1 if same direction)
d1 = targTri_co(2,:)-targTri_co(1,:);
d2 = targTri_co(3,:)-targTri_co(1,:);
sameDir = sign(dot(cross(d1,d2),targTri_norm));

% if -1, going wrong direction! - reverse order of boundary pounts
if sameDir == -1
    bPts = bPts(end:-1:1);
end

%--------------------------------------------------------------------------

adjMat = adjacency(obj.G);

% get all adjacent points to boundary points (excl. boundary points)
adjPts = unique(mod(find(adjMat(:,bPts))-1,obj.nVert)+1);
adjPts(ismember(adjPts,bPts)) = [];

% iterate over that list, finding points *only* connected to BPs
cBP_only = false(numel(adjPts));
for ii = 1:numel(adjPts)
    
    % get all adjacent points to current point
    currAdj = find(adjMat(:,adjPts(ii)));
    
    if all(ismember(currAdj,bPts))
        
        % test if point is inside boundary or not
        
        
        
    end
end
cBP_only = adjPts(cBP_only);

