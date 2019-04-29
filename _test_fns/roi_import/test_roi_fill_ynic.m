
% https://computergraphics.stackexchange.com/questions/5377/how-can-i-perform-a-triangle-inside-test-in-polygon-meshes

tmp = load('/scratch/home/r/rv519/matSurf/tmpROIdata.mat');
bPts = double(tmp.bPts);
midPt = tmp.midPt;
clearvars tmp;

obj = load('/scratch/home/r/rv519/matSurf/_test_fns/roi_import/vol.mat');
obj = obj.R3517_rh_inf;

bPts = bPts(end:-1:1);

%% initial processing on boundary points
 
% find and extract points where bound reverses on itself (single connected BPs)
sBPts_idx = (circshift(bPts,-1)==circshift(bPts,1));
sBPts = bPts(sBPts_idx);
bPts(sBPts_idx) = [];

% find and remove points where a boundary point is repeated
bPts(bPts==circshift(bPts,-1)) = [];

% set num bound points
nBP = numel(bPts);

%%

% find furthest point from centre of boundary (will be end point)
boundCent = mean(obj.TR.Points(bPts,:));
[~,endPt] = max(sqrt(sum(bsxfun(@minus,obj.TR.Points,boundCent).^2,2)));

% pick random boundary adjacent point
stPnt = [];
inc = 1;
while isempty(stPnt)
    stPnt = neighbors(obj.G,bPts(inc));
    stPnt(ismember(stPnt,bPts)) = [];
    inc = inc +1;
end
stPnt = stPnt(1);

test = zeros(obj.nVert,1);
test(bPts) = 1;
toTest = setdiff(1:obj.nVert,bPts)';

for ii = 1:numel(toTest)
    
    stPnt = toTest(ii);
    
    % calculate shortest path from start to furtherst point
    % only saving whether boundary point or not
    sPath = ismember(shortestpath(obj.G,stPnt,endPt),bPts);
    
    % delete any repeated adjacent points (e.g. travelling across boundary)
    sPath(diff(sPath)==0) = [];
    
    % test if in boundary
    pt_inBound = mod(sum(sPath),2);
    
    test(stPnt) = pt_inBound;
end

%%

% % get all triangles attached to a boundary point
% allBPtris = vertexAttachments(obj.TR,bPts);
% 
% % find index of triangles that share adjacent boundary edges (BPtris_idx)
% % (i.e. if BP(n) and BP(n-1) share triangle, store that triangle)
% BPtris_idx = zeros(nBP,2);
% int_idx = false(max([allBPtris{:}]),1); % index for faster version of intersect
% int_idx(allBPtris{end}) = 1; % starting with BP1 so prev. point is at end
% for currBP = 1:nBP
%     % do faster intersect
%     BPtris_idx(currBP,:) = allBPtris{currBP}(int_idx(allBPtris{currBP}));
% 
%     % update intersect index to have current (aka 'prev') vals
%     int_idx(:) = 0;
%     int_idx(allBPtris{currBP}) = 1;
% end
% BPtris_idx = [BPtris_idx(:,1); BPtris_idx(:,2)]; % collapse cols

% find index of triangles that share adjacent boundary edges (BPtris_idx)
BPtris_idx = cell2mat(edgeAttachments(obj.TR,bPts,circshift(bPts,1)));
BPtris_idx = [BPtris_idx(:,1); BPtris_idx(:,2)]; % collapse cols

% create list of all points (as points, and also logical vals if point=BP)
% (transposing so each face is seperate column, because matlab reads row-wise)
BPtris_pnt = obj.TR.ConnectivityList(BPtris_idx,:)';
BPtris_log = ismember(BPtris_pnt,bPts);

% find and delete any faces that are completely enclosed by boundary points
enclFace = find(all(BPtris_log));
BPtris_idx(enclFace)   = [];
BPtris_pnt(:,enclFace) = [];
BPtris_log(:,enclFace) = [];

% get the non-BP points, aka points adj to BP edge
BPtris_adj = BPtris_pnt(~BPtris_log);

% create new list of tri points based on known edge order
% (from now on, not transposed so each row = seperate face)
triList = repmat([circshift(bPts,1), bPts],2,1);
triList(enclFace,:) = [];
triList = [triList, BPtris_adj];

% get normals for each triangle
BPtris_nrm = faceNormal(obj.TR,BPtris_idx);

% cross prod. each triangle, then take dot prod. with face normal
d1 = obj.TR.Points(triList(:,2),:)-obj.TR.Points(triList(:,1),:);
d2 = obj.TR.Points(triList(:,3),:)-obj.TR.Points(triList(:,1),:);
tri_inBound = sign(dot(cross(d1,d2,2),BPtris_nrm,2))==1;

% get points in bound
pts_inBound = unique(BPtris_adj(tri_inBound));

%%

allCoords = obj.TR.Points(pts_inBound,:);

tmpPlot = line(h.xForm,allCoords(:,1),allCoords(:,2),...
    allCoords(:,3),'Color','red','LineStyle','none','Marker','.');


