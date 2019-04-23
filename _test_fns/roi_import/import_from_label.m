
% save handles as h, surface as vol

% h.brainPatch.EdgeColor = 'k';

% % create graph
% st = edges(vol.TR);
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(st(:,1),:),vol.TR.Points(st(:,2),:)).^2,2));
% G = graph(st(:,1),st(:,2),w);

% % create global adjanceny matrix
% AM = sparse([st(:,1);st(:,2)], [st(:,2);st(:,1)],...
%     ones(length(st)*2,1), vol.nVert, vol.nVert);

% load in ROI
roiExp = load('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/RH_testROI.mat');
roiExp = roiExp.R3517_rh_ROIs;

% get all and selected vertices
allVert = roiExp.ROIs.allVert{1};
allVert(isnan(allVert)) = [];
selVert = roiExp.ROIs.selVert{1};

% load in label
fid = fopen('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/RH_testROI.label','r') ;
fgets(fid);
nV = fscanf(fid,'%d\n',1);
roiLab = fscanf(fid, '%d %*f %*f %*f %*f\n',[1 nV])' +1;
fclose(fid);

clearvars st w fid nV;

%%

% find all boundary points (will be points that have at least one
% connection outside ROI, can find with xor)
toKeep = false(vol.nVert,1);
toKeep(roiLab) = true;
e = edges(vol.TR);
tmpBoundPts = intersect(e(xor(toKeep(e(:,1)),toKeep(e(:,2))),:),roiLab);

% get only edges connecting boundary points
toKeep(:) = 0;
toKeep(tmpBoundPts) = true;
e(~all(toKeep(e),2),:) = [];

% grab the weights for each edge
% w = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));

% relabel vertices so they're 1:n just to make life easier
[unE,e_idx,unE_idx] = unique(e);
nE = numel(unE);
unE_alt = (1:nE)';
e(:) = unE_alt(unE_idx);

% create adjacency matrix
adjMat = false(nE);
adjMat(sub2ind([nE,nE],[e(:,1);e(:,2)],[e(:,2);e(:,1)])) = 1;
nCon = sum(adjMat);

% make a graph
w = sqrt(sum(bsxfun(@minus,vol.TR.Points(e(:,1),:),vol.TR.Points(e(:,2),:)).^2,2));
g2 = graph(e(:,1),e(:,2),w);
figure; plot(g2,'Layout','force');

% find awkward points (connectivitity ~= 2)
singPts = find(nCon==1);
multPts = find(nCon>2);

% pick a vertex and run with it

stPnt = 34;
trgPnt = 27; % say we found it...

allPaths = zeros(1000,100,'uint32');

adj1 = find(adjMat(:,ii));
adj1(ad





