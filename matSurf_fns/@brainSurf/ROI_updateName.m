function ROI_updateName(obj,oldName,newName)
% function to update an ROI name
%
% (req.) oldName, current name of ROI
% (req.) newName, new name of ROI

% look up ROI
ROI_ind = find(strcmpi({obj.ROIs.name},oldName),1);
if isempty(ROI_ind)
    warning('Could not find requrested ROI, not renaming');
    return
end

% change name
obj.ROIs(ROI_ind).name = newName;

% update all ROI names
obj.roiNames{ROI_ind} = newName;

end