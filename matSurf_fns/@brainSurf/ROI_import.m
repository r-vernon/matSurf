function [vCoords] = ROI_import(obj,newROIs)
% TODO - implement this properly!

% add new ROIs to ROI store
obj.ROIs.name    = [obj.ROIs.name    ; newROIs.name];
obj.ROIs.nVert   = [obj.ROIs.nVert   ; newROIs.nVert];
obj.ROIs.allVert = [obj.ROIs.allVert ; newROIs.allVert];
obj.ROIs.selVert = [obj.ROIs.selVert ; newROIs.selVert];
obj.ROIs.visible = [obj.ROIs.visible ; newROIs.visible];

% update nROIs
obj.nROIs = obj.nROIs + length(newROIs.name);

% update current ROI if there were no ROIs before
if obj.currROI == 0
    obj.currROI = obj.nROIs;
end

% find ROIs that haven't been finished yet (+1 due to end nan)
unfinROI = cellfun(@numel,obj.ROIs.allVert) > obj.ROIs.nVert +1;

% update lineInd with finished ROIs
obj.ROI_lineInd = [nan; cell2mat(obj.ROIs.allVert(~unfinROI))];

%--------------------------------------------------------------------------
% set return variables

% get actual vertex coords to return
vCoords = obj.ROI_get;

end