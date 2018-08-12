function ROI_fin(obj)
% function to finish an ROI, i.e. lock it down for editing
%
% (set.) ROIs,        structure containing all ROI details
% (set.) ROI_lineInd, vertices of all finished ROIs

% grab the ROI index
ind = obj.currROI;

% make sure ROI isn't already finished
if isnan(obj.ROIs.allVert{ind}(end))
    return
end

% get end positions for all/selected vertices
allV_end = obj.ROIs.nVert(ind) +1;
selV_end = nnz(obj.ROIs.selVert{ind}) +1;

% append a 'nan' at the end of allVert to show it's finished
obj.ROIs.allVert{ind}(allV_end) = nan;
allV_end = allV_end + 1;

% clear any additional padding in all/selected vertices
obj.ROIs.allVert{ind}(allV_end:end) = [];
obj.ROIs.selVert{ind}(selV_end:end) = [];

% find ROIs that haven't been finished yet (+1 due to end nan)
unfinROI = cellfun(@numel,obj.ROIs.allVert) > obj.ROIs.nVert +1;

% update lineInd with finished ROIs
% overwriting completely in case edited ROI wasn't at end for some reason
obj.ROI_lineInd = [nan; cell2mat(obj.ROIs.allVert(~unfinROI))];

end