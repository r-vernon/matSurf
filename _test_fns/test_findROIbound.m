
st = edges(vol.TR);
w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
G = graph(st(:,1),st(:,2),w);

% find all boundary points (will be points that have at least one
% connection outside ROI, can find with xor)
toKeep = false(vol.nVert,1);
toKeep(data) = true;
E = edges(vol.TR);
tmpBoundPts = intersect(E(xor(toKeep(E(:,1)),toKeep(E(:,2))),:),data);
maxV = max(tmpBoundPts);

% get only edges connecting boundary points
toKeep(:) = 0;
toKeep(tmpBoundPts) = true;
E(~all(toKeep(E),2),:) = [];

% create sparse matrix to contain edges 
adjMat = sparse([E(:,1);E(:,2)], [E(:,2);E(:,1)],...
    ones(length(E)*2,1), maxV,maxV);
nCon = sparse(1:maxV,ones(maxV,1),...
    sum(adjMat),maxV,1);

% preallocate for ordered bound points, and used nodes
allVert = zeros(size(tmpBoundPts));
usedN = false(maxV,1);

% set first point (making sure we don't start at 3 conn. point)
ind = 1;
while nnz(adjMat(:,tmpBoundPts(ind))) > 2
    ind = ind+1;
end
cPnt = tmpBoundPts(ind);
allVert(1) = cPnt;
usedN(cPnt) = 1;

% set second point to set direction
cPnt = find(adjMat(:,cPnt),1);

for ind = 2:length(allVert)
    
    if ind==72, break; end
    if any(cPnt==11487), break; end
    
    if length(cPnt) > 1

        % set cPnt as if ran another loop
        % (dependent upon which node is 'isolated' after edge removal)
        if isempty(setdiff(find(adjMat(:,cPnt(1)) & ~usedN),cPnt))
            allVert(ind) = cPnt(1);
            usedN(cPnt(1)) = 1;
            cPnt = find(adjMat(:,cPnt(2)) & ~usedN);
        else
            allVert(ind) = cPnt(2);
            usedN(cPnt(2)) = 1;
            cPnt = find(adjMat(:,cPnt(1)) & ~usedN);
        end
        
        % tell to skip an iteration
        continue;
    end
    
    % mark current point as visited
    allVert(ind) = cPnt;
    usedN(cPnt) = 1;
    
    % find next point
    cPnt = find(adjMat(:,cPnt) & ~usedN);
    
end

%--------------------------------------------------------------------------

% find a starting point
sPaths = shortestpathtree(G,allVert(1),'Method','pos','OutputForm','vect')';
toShift = find(any(sPaths(allVert(2:end))-allVert(1:end-1),2),1);
allVert = circshift(allVert,-toShift +1);

selVert = false(length(allVert),1);
selVert(1) = 1;

ind = 1;
while ~isempty(ind)
    sPaths = shortestpathtree(G,allVert(ind),'Method','pos','OutputForm','vect')';
    ind = (ind-1) + find(any(sPaths(allVert(ind+1:end))-allVert(ind:end-1),2),1);
    selVert(ind) = 1;
end
selVert = allVert(selVert);


delete(tmpPl);
xyz = vol.TR.Points(tmpBoundPts,:);
tmpPl = plot3(handles.xForm,xyz(:,1),xyz(:,2),xyz(:,3),'r.');