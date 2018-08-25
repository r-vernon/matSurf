function [colData] = checkColRange(colData)
% function to make sure colours lie in range 0:1
%
% if not in range, checks to see if range is 0:255 (min >=0, max <= 255),
% or -1:+1 (min >=-1, max <= 1), then rescales appropriately... failing
% that, just forces range to 0:1
%
% (req.) colData, array of data whose range you want to check
% (ret.) colData, array

%--------------------------------------------------------------------------

% get the data mins/maxes
currMin = min(colData(:));
currMax = max(colData(:));

% first, is it actually outside the range at all...
if currMin < 0 || currMax > 1
    
    % preallocate old range and set new range
    oldMinMax = [];
    newMinMax = [0,1];
    
    if currMin >= 0 && currMax <= 255 % within range [0:255]?
        oldMinMax = [0,255];
    elseif currMin >= -1 && currMax <= 1 % within range [-1:+1]?
        oldMinMax = [-1,1]; 
    end
    
    % set new range
    colData = setRange(colData,newMinMax,oldMinMax);
    
end


end