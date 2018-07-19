function [success,ind] = ROI_remove(obj,toDel)
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

% preset sucess to false 
success = false;

%==========================================================================
% grab details of selected ROI

stPos  = obj.pROIs(toDel).stPos;
endPos = obj.pROIs(toDel).endPos;

if isempty(endPos) 
    % ROI not finished so find how many points created
    finROI = false;
    % say 3 points starting at 2, [x,1,2,3,x...], endPos st+(n-1) = 4
    endPos = stPos + nnz(obj.ROIs(toDel).allVert) - 1;
else
    finROI = true;
    endPos = endPos + 1; % ROI finished, so account for NaN
end

nToDel = endPos - stPos + 1;

%==========================================================================
% delete ROI

obj.ROIs(toDel)  = []; % clear from public ROIs list
obj.pROIs(toDel) = []; % clear from private ROIs list
obj.ROI_sPaths   = []; % might as well clear sPaths as well

% delete from line indices
obj.ROI_lineInd(stPos:endPos) = 0;

% may need to shuffle points up
if obj.nROIs > 1
    
    toMove = find([obj.pROIs(:).stPos] >  endPos);
    if ~isempty(toMove)
        for currROI = 1:length(toMove)
            obj.pROIs(currROI).stPos = obj.pROIs(currROI).stPos - nToDel;
            if ~isempty(obj.pROIs(currROI).endPos)
                obj.pROIs(currROI).endPos = obj.pROIs(currROI).endPos - nToDel;
            end
        end
    end
end



%==========================================================================

% seem to have made it this far! remove requested overlay
obj.dataOvrlay(ovrlayInd) = [];

% work out what to show now
if obj.nOvrlays == 1 % removed only overlay
    obj.currOvrlay = obj.baseOvrlay;
    ind = 0;
else
    % e.g. if have ovrlay 1, 2, 3 and ovrlayInd = 2, ovrlay now 1, 3 so
    % want ind=1, however if ovrlayInd = 1, ovrlay now 2,3 so want ind=1
    if ovrlayInd > 1
        ind = ovrlayInd - 1;
        obj.currOvrlay = obj.dataOvrlay(ind); % show prev. overlay
    else
        ind = ovrlayInd;
        obj.currOvrlay = obj.dataOvrlay(ind); % show next overlay
    end
end

% update roiNames and nROIs
obj.ovrlayNames = {obj.ROIs(:).name};
obj.nROIs = length(obj.ROIs);

success = true; % yay

end
