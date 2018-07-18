function [success] = ovrlay_set(obj,ovrlay)
% function to set current overlay
%
% (req.) ovrlay, overlay to load either as an index, or as a string
%        if set to 0 or 'base', returns base overlay
% (ret.) success, true if overlay set successfully
% (set.) currOvrlay, sets to selected overlay


% preset sucess to false
success = false;

%==========================================================================

% look up the requested overlay
ovrlayInd = obj.ovrlay_find(ovrlay);

if isempty(ovrlayInd)
    warning('Could not set selected overlay');
    return
end

%==========================================================================

% seem to have made it this far! set currOvrlay to requested overlay
if ovrlayInd == 0
    obj.currOvrlay = obj.baseOvrlay;
else
    obj.currOvrlay = obj.dataOvrlay(ovrlayInd);
end
success = true; % yay

end
