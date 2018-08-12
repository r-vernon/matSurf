function [success] = ROI_updateName(obj,oldName,newName)
% function to update an ROI name
%
% (ret.) success, true if successfully renamed
% (req.) oldName, current name of ROI
% (req.) newName, new name of ROI

success = false;

% look up ROI
ROI_ind = find(strcmp(obj.ROIs.name,oldName),1);

% if can't rename, quit
if isempty(ROI_ind), return; end

% change name
obj.ROIs.name{ROI_ind} = newName;

success = true;

end