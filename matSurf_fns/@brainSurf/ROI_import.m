function [vCoords] = ROI_import(obj,newROIs)
% TODO - implement this properly!

% get current ROI index
ind = obj.nROIs;

% get start positions for new vertices in line indices
if ind == 0
    lStPos = 1;
else
    lStPos = obj.pROIs(ind,3) + 2; % plus 2 as 'jumping' over NaN
end

% move ind to next ROI pos
ind = ind + 1;

%--------------------------------------------------------------------------

% count number ROIs to add and create indices
n2add = length(newROIs);
rInd = ind:ind+n2add-1;

% update currVol
obj.currVol = ind + n2add - 1;

% get vertices of all new ROIs
newVert = {newROIs.allVert};
newVert = newVert(:);

% preallocate for length of each ROI
lenROI = zeros(n2add,1);

% make sure every cell loops back to start and ends in 'NaN'
for cROI = 1:n2add
    if ~isnan(newVert{cROI}(end))
        if newVert{cROI}(end) == newVert{cROI}(1)
            newVert{cROI}(end+1) = nan;
        else
            newVert{cROI}(end+1:end+2) = [newVert{cROI}(1),nan];
        end
    end
    
    % calc. length
    lenROI(cROI) = length(newVert{cROI});
end

% collapse
newVert = cell2mat(newVert);

% calc. line ending position
nPts2add = length(newVert);
lEndPos = lStPos + nPts2add - 1;

%--------------------------------------------------------------------------

% set public details
obj.ROIs(rInd) = newROIs;

% update roiNames and nROIs
obj.roiNames = {obj.ROIs(:).name};
obj.nROIs = length(obj.ROIs);

% set private details
obj.pROIs(rInd,1) = rInd;
obj.pROIs(rInd,2) = cumsum([lStPos;lenROI(1:end-1)]);
obj.pROIs(rInd,3) = obj.pROIs(rInd,2) + lenROI -2; % -2 as ignore end nan

% make sure arrays can hold new points
obj.ROI_lineInd = expandArray(obj.ROI_lineInd, 1e5, nPts2add);

% add points
obj.ROI_lineInd(lStPos:lEndPos) = newVert;

%--------------------------------------------------------------------------
% set return variables

% get vertex indices
vertInd = obj.ROI_lineInd(1:lEndPos);

% get actual vertex coords to return
vCoords = obj.ROI_get(vertInd);

end