function [success,vCoords] = ROI_remove(obj,ROIname)
% function to remove overlay
%
% (req.) ROIname,     name of ROI to remove
% (ret.) success,     true if ROI removed successfully
% (ret.) vCoords,     vertex coords to plot with line
% (set.) ROIs,        structure containing all ROI details
% (set.) nROIs,       number of ROIs
% (set.) ROI_lineInd, vertices of all finished ROIs
% (set.) currROI,     currently selected ROI (0 if all ROIs deleted)

% preset sucess to false  and vCoords to empty
success = false;
vCoords = [];

%==========================================================================
% grab details of selected ROI

% look up ROI
ind = find(strcmp(obj.ROIs.name,ROIname),1);

% if couldn't find it, return
if isempty(ind), return; end
    
% check if ROI was finished
if contains(obj.ROIs.name{ind},'[e]') || numel(obj.ROIs.allVert{ind}) > obj.ROIs.nVert(ind) +1
    wasFin = false;
else
    wasFin = true;
end

% delete the ROI
obj.ROIs.name(ind)    = [];
obj.ROIs.nVert(ind)   = [];
obj.ROIs.allVert(ind) = [];
obj.ROIs.selVert(ind) = [];
obj.ROIs.visible(ind) = [];

% reduce ROI count
obj.nROIs = obj.nROIs -1;

% if ROI was finished, update lineInd (which only contains finished ROIs)
if wasFin
    % find ROIs that haven't been finished yet (+1 due to end nan)
    unfinROI = cellfun(@numel,obj.ROIs.allVert) > obj.ROIs.nVert +1;
    
    % update lineInd with finished ROIs
    obj.ROI_lineInd = [nan; cell2mat(obj.ROIs.allVert(~unfinROI))];
end

% update current ROI
if obj.nROIs == 0 % have removed only ROI
    obj.currROI = 0;
elseif ind > 1
    obj.currROI = ind - 1;
else
    obj.currROI = ind;
end

% get vertex coords to return (if not deleted all ROIs)
if obj.nROIs > 0
    vCoords = obj.ROI_get;
end

success = true;

end
