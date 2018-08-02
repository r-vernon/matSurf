
st = edges(vol.TR);
w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
G = graph(st(:,1),st(:,2),w);





toKeep = false(vol.nVert,1);
toKeep(data) = true;
E = edges(vol.TR);
boundPts = intersect(E(xor(toKeep(E(:,1)),toKeep(E(:,2))),:),data);


% find starting point
toKeep = false(vol.nVert,1);
toKeep(boundPts) = true;
sPaths = shortestpathtree(G,boundPts(1),...
    'Method','positive','OutputForm','vector')';
for ind = 1:length(boundPts)
    cPntConn = find(toKeep & sPaths==cPnt(ind),1);
    toKeep(cPnt(ind)) = 0;
    cPnt(ind+1) = cPntConn;
end

selVertInd = false(vol.nVert,1);
cPnt = zeros(length(boundPts),1);
cPnt(1) = boundPts(1);

for ind = 1:length(boundPts)
    
    cPntConn = find(toKeep & sPaths==cPnt(ind),1);
    if isempty(cPntConn)
        selVertInd(cPnt(ind)) = 1;
        sPaths = shortestpathtree(G,cPnt(ind),...
            'Method','positive','OutputForm','vector')';
        cPntConn = find(toKeep & sPaths==cPnt(ind),1);
        if isempty(cPntConn)
            cPntConn = find(sPaths==cPnt(ind),1);
        end
    end
    toKeep(cPnt(ind)) = 0;
    cPnt(ind+1) = cPntConn;
end








sPaths(allVert(2))

x = plot3(handles.xForm, P(:,1),P(:,2),P(:,3),'r.');
x2 = plot3(handles.xForm, ...
    vol.TR.Points(boundPts,1),...
    vol.TR.Points(boundPts,2),...
    vol.TR.Points(boundPts,3),'r.');