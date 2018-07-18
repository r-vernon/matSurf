function [ovrlayData] = ovrlay_get(obj,ovrlay)
% function to get an overlay
%
% (req.) ovrlay, overlay to get, either as an index, or as a string
%        if set to 0 or 'base', returns base overlay
% (ret.) ovrlayData, the data structure for the requested overlay

% preset ovrlayData to empty, in case can't acquire
ovrlayData = [];

%==========================================================================

% look up the requested overlay
ovrlayInd = obj.ovrlay_find(ovrlay);

if isempty(ovrlayInd)
    warning('Could not get selected overlay');
    return
end

%==========================================================================

% seem to have made it this far! set ovrlayData to requested overlay
if ovrlayInd == 0
    ovrlayData = obj.baseOvrlay;
else
    ovrlayData = obj.dataOvrlay(ovrlayInd);
end

end
