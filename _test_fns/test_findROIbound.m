
allVert = data;
toKeep = zeros(vol.nVert,1);
toKeep(allVert) = allVert;

T = vol.TR.ConnectivityList(all(toKeep(vol.TR.ConnectivityList),2),:);
T = toKeep(T);
P = vol.TR.Points(allVert,:);

% calculate temp triangulation
% (temporarily turning off warning about not referencing all points)
warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
tmpTR = triangulation(T,P);
warning('on','MATLAB:triangulation:PtsNotInTriWarnId');

% get free boundary points
allVert = tmpTR.freeBoundary;

cl_toDel = any(toKeep(vol.TR.ConnectivityList),2);
tmpTR = triangulation(vol.TR.ConnectivityList(~cl_toDel,:),...
    vol.TR.Points(~toKeep));

allVert = tmpTR.

selVertInd = false(length(data));

sPaths = shortestpathtree(G,allVert(1),...
    'Method','positive','OutputForm','vector')';

sPaths(allVert(2))
