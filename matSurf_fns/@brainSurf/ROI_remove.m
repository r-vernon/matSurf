function [success,ind,vCoords] = ROI_remove(obj,ROIname)
% function to remove overlay
%
% (req.) ovrlay, overlay to remove either as an index, or as a string
% (ret.) success, true if overlay removed successfully
% (ret.) ind, index of overlay to show next (0 if base)
% (set.) dataOvrlay, updates it now ovrlay removed
% (set.) ovrlayNames, cell array containing names of all loaded data overlays
% (set.) nOvrlays, number of overlays
% (set.) currOvrlay, sets current overlay to previous overlay, next
%        overlay or base overlay in order of preference

% TODO - update text above!

% preset sucess to false  and others to empty
success = false;
ind = [];
vCoords = [];

%==========================================================================
% grab details of selected ROI

% look up ROI
ROI_ind = find(strcmpi({obj.ROIs.name},ROIname),1);
if isempty(ROI_ind)
    warning('Could not find requrested ROI, not deleting');
    return
end
pROI_ind = find(obj.pROIs(:,1)==ROI_ind,1);

% grab start and end position of ROI
stPos  = obj.pROIs(pROI_ind,2);
endPos = obj.pROIs(pROI_ind,3);

% if ROI not finished, find how many points created
if endPos == 0
    % (say 3 points starting at 2, [x,1,2,3,x...], endPos = stPos +(n-1) = 4)
    endPos = stPos + (nnz(obj.ROIs(ROI_ind).allVert) -1);
else
    endPos = endPos +1; % ROI finished, so account for NaN
end

% count how many points to delete
nToDel = endPos - stPos + 1;

%==========================================================================
% overwrite the ROI to be deleted and update indices

% delete from line indices
obj.ROI_lineInd(stPos:endPos) = 0;
newEndPos = stPos -1;

% grab all start positions, and find last ROI (latest start)
allSt = obj.pROIs(:,2);
[mSt,mStInd] = max(allSt);

% if any ROIs start after end of deleted ROI, shift them
if mSt > endPos
    
    % find all ROIs that start after deleted ROI
    toMove = find(allSt > endPos);
    
    % shift actual indices in ROI_lineInd
    mEnd = obj.pROIs(mStInd,3);
    if mEnd == 0
        % change mStInd to point to public ROIs list
        mStInd = obj.pROIs(mStInd,1); 
        % count how many indices have been added in identified ROI
        mEnd = mSt + nnz(obj.ROIs(mStInd).allVert) - 1;
    else
        mEnd = mEnd + 1;
    end
    newEndPos = mEnd-nToDel;
    obj.ROI_lineInd(stPos:newEndPos) = obj.ROI_lineInd(endPos+1:mEnd);
    obj.ROI_lineInd(newEndPos+1:mEnd) = 0;
    
    % update ROI_lineInd mappings to account for above shift
    % (making sure endPos can't go below 0 if not finished yet)
    obj.pROIs(toMove,2:3) = obj.pROIs(toMove,2:3) - nToDel;
    obj.pROIs(toMove(obj.pROIs(toMove,3)<0),3) = 0;
    
    % update index to public ROI list to account for upcoming deletion
    obj.pROIs(toMove,1) = obj.pROIs(toMove,1) - 1;
    
end

%==========================================================================
% delete ROI

% delete from public and private ROI lists
obj.ROIs(ROI_ind)     = []; 
obj.pROIs(pROI_ind,:) = []; 

% make sure pROIs isn't getting full after deleting row
obj.pROIs = expandArray(obj.pROIs, 10, 1);

% work out what to show now
if obj.nROIs == 1 % will have removed only overlay
    ind = 0;
elseif ROI_ind > 1
    ind = ROI_ind - 1;
else
    ind = ROI_ind;
end

% update roiNames and nROIs
obj.roiNames = {obj.ROIs(:).name};
obj.nROIs = length(obj.ROIs);

% get vertex coords to return (unless deleted all ROIs)
if obj.nROIs > 0
    vCoords = obj.ROI_get(obj.ROI_lineInd(1:newEndPos));
else
    vCoords = [];
end

success = true; % yay

end
