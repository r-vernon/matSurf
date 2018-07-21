
% handles.brainPatch.EdgeColor = 'none';
% handles.brainPatch.EdgeColor = 'black';

delete(vertSel);
vertSel = line(handles.xForm,'Tag','vertSel',...
    'Color','red','Marker','.','MarkerFaceColor','red','PickableParts','none',...
    'LineStyle','none','Visible','on');

XYZ = R3517_rh_in.TR.Points(allV,:);
set(vertSel,...
    'XData',[],...
    'YData',[],...
    'ZData',[]);



% allPts = R3517_rh_in.ROIs(2).allVert;
midPt  = 1;%nearestNeighbor(TR,mean(TR.Points(allPts,:)));
nVert  = length(R3517_rh_in.TR.Points);

surf_coneMarker(handles.matSurfFig,midPt);

%-------------

% breadth first test
tic;

% record which points have been visited
vis = false(nVert,1);
vis([allPts;midPt]) = true;

% record which points should be visited
% toVis = zeros(nVert,1,'uint32');
toVis = midPt;

% create (sparse) adjacency matrix
adjMat = logical(adjacency(G));

while ~isempty(toVis) % while there's points to be visited

    % get neighbours of current point
    currN = unique(mod(find(adjMat(:,toVis))-1,nVert)+1);

    % delete any that have been visited
    currN(vis(currN)) = [];
    
    % mark points added to list as visited
    vis(currN) = true;

    % update toVis with neighbours
    toVis = currN;

end

allV = find(vis);

toc

set(vertSel,...
    'XData',R3517_rh_in.TR.Points(vis,1),...
    'YData',R3517_rh_in.TR.Points(vis,2),...
    'ZData',R3517_rh_in.TR.Points(vis,3));
drawnow;
