function [success,ind] = ovrlay_remove(obj,ovrlay)
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

% preset sucess to false and ind to empty
success = false;
ind = [];

%==========================================================================
% look up requested overlay

ovrlayInd = obj.ovrlay_find(ovrlay);

% make sure haven't requested base overlay
if ovrlayInd == 0 || isempty(ovrlayInd)
    warning("Can't remove selected overlay");
    return;
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

% update ovrlayNames and nOvrlays
obj.ovrlayNames = {obj.dataOvrlay(:).name};
obj.nOvrlays = length(obj.dataOvrlay);

success = true; % yay

end
