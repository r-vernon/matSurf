function [newData] = setRange(currData,trgMinMax,oldMinMax)
% function to make sure data doesn't exceed specified range
%
% (req.) currData, data array whose range needs change
% (req.) trgMinMax, target minimum and maximum (e.g. [0,1])
% (opt.) oldMinMax, old/original minimum and maximum (e.g. [0,255]), so:
%         - setRange([127.5,255],[0,1])         = [0.0,1.0]
%         - setRange([127.5,255],[0,1],[0,255]) = [0.5,1.0]
% (ret.) newData, data array with same shape as currData, set to new range

%--------------------------------------------------------------------------

% check if an old range is specified
if nargin < 3 || isempty(oldMinMax)
    useOldRange = false;
else
    useOldRange = true;
    
    % get the old mins/maxes
    oldMin = min(oldMinMax);
    oldMax = max(oldMinMax);
    oldRange = oldMax - oldMin;
end

% get the target mins/maxes, plus range
trgMin = min(trgMinMax);
trgMax = max(trgMinMax);
trgRange = trgMax - trgMin;

% reshape data (saving dataDim to undo later)
dataDim = size(currData);
currData = currData(:);

% get the data mins/maxes
currMin = min(currData);
currMax = max(currData);
currRange = currMax - currMin;

%--------------------------------------------------------------------------

% is using old range, make sure data fits inside that range
if useOldRange
    
    if currMin < oldMin || currMax > oldMax
        warning("Data lies outside specified old range, ignoring old range as not valid");
    else
        % oldRange is valid so update current min and range with provided values
        currMin = oldMin;
        currRange = oldRange;
    end
    
elseif currRange == 0
    
    % not using old range, so make sure currData has valid range (i.e. not 0)
    warning("Range of provided data is 0 so can't rescale - returning mean of new range");
    newData = mean(trgMinMax);
    return
    
end

%--------------------------------------------------------------------------

% now rescale 
newData = (trgRange*(currData-currMin))/currRange + trgMin;

%{ 
e.g. for [15,50,85] to [-20,40]...
- (60*([15,50,85]-15))/70 + -20
- (60*([0,35,70]))/70 - 20
- ([0,2100,4200])/70 - 20
- [0,30,60] - 20
- [-20,10,40]
%}

% and undo reshaping
newData = reshape(newData,dataDim);

end
