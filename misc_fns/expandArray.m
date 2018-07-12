function [currArray,sizeInc] = expandArray(currArray,baseSize,num2Add,fillThr)
% function to check filled status of an array, if more than 75% 
% (or 'fillThresh'%) used, expands by baseSize (note - an empty array would
% be all zeros)
%
% (req.) currArray, array whos size to check, must be vector
% (req.) baseSize,  how many points to add if array needs expanding
% (opt.) num2add,   how many points are going to be added (default = 1)
% (opt.) fillThr,   threshold at which to expand array (range 0:1 or 1:100)
% (ret.) currArray, either copy or expanded version of currArray
% (ret.) sizeInc,   true if size increased

sizeInc = false;

%--------------------------------------------------------------------------
% parse inputs

% parse num2add
if nargin < 3
    num2Add = 1;
elseif isempty(num2Add) || ~isscalar(num2Add) || ~isnumeric(num2Add)
    warning('Invalid num2Add specified, using default (1)');
    num2Add = 1;
end

% parse fillThresh
if nargin < 4
    fillThr = 0.75;
elseif isempty(fillThr) || ~isscalar(fillThr) || ~isnumeric(fillThr)
    warning('Invalid threshold specified, using default (75%)');
    fillThr = 0.75;
elseif fillThr <= 0 || fillThr >= 1
    if fillThr > 0 && fillThr < 100 % check if entered in range 0:100
        fillThr = fillThr/100;
    else
        warning('Invalid threshold specified, using default (75%)');
        fillThr = 0.75;
    end
end

% make sure currArray is vector
if ~isvector(currArray) || ~isnumeric(currArray)
    warning('Can only expand numeric vector arrays');
    return
end

%--------------------------------------------------------------------------
% check if too full

% get length and current filled state of currArray
amntUsed  = find(currArray~=0,1,'last');
amntAvail = length(currArray);

if (amntUsed + num2Add) > (fillThr * amntAvail)
    if iscolumn(currArray)
        currArray = [currArray ; zeros(baseSize,1,'single')];
    else
        currArray = [currArray , zeros(1,baseSize,'single')];
    end
    sizeInc = true;
end

end