function [success,ind] = ovrlay_add(obj,newOvrlay,varargin)
% function to add an additional overlay, e.g. retinotopy or Z-Stats
%
% (req.) newOvrlay, new overlay that you want to load, can be passed in
%        either as data, or as a path to the data
% (opt.) ovrlayName, name of the overlay, if not provided either takes the
%        basename of the path, or variable name of data
%
% - The following optional inputs can be provided as name-value pairs -
%
% (opt.) dLim, data limits, if set data is lower thresholded at min(dLim)
%        and upper thresholded at max(dLim)
% (opt.) cmap, colormap to use (if not specified, uses default)
% (opt.) cLim, format [lower bound, upper bound], color limits for colormap 
%        (if set, colors < min(ulBound) or colors > max(ulBound) set to 
%        color values for min(ulBound)/max(ulBound) respectively)
% (opt.) altBase, by default where ovrlay == 0 will be set to 
%        transparent, but if e.g. altBase set to nan, then ovrlay will 
%        be transparent where isnan(ovrlay)
% (ret.) success, true if data loaded successfully, false if not
% (ret.) ind, index of newly loaded data overlay
% (set.) obj.dataOvrlay, surface overlay structure containing name, data, 
%        colormap and mask of new overlay
% (set.) ovrlayNames, cell array containing names of all loaded data overlays
% (set.) nOvrlays, number of overlays
% (set.) obj.currOvrlay, sets current overlay to newly added overlay
%
% Note:  for dLim, cLim, set either bound to nan to ignore that bound
%        i.e. [0,nan] constrains to [0,max(newOvrlay)]

% preset sucess to false and ind to nan
success = false;
ind = nan;

% make sure a surface is loaded
if isempty(obj.nVert)
    warning('No surface loaded, not adding overlay');
    return
end

%==========================================================================
% parse optional inputs

% set up default overlay name, depending on if path or index passed
if ischar(newOvrlay)
    [~,defName,~] = fileparts(newOvrlay);
    defName = extractBefore(defName,'.'); % remove any extra extensions
else
    defName = inputname(2);
end

% set input checks
validNum1 = @(x) isnumeric(x) && isvector(x) && numel == 1;
validNum2 = @(x) isnumeric(x) && isvector(x) && numel == 2;

% add in arguments and parse them
% addOptional - positional, must stay in place
% addParameter - specified as name-value pair
p = inputParser;
addOptional(p,'ovrlayName',defName);
addParameter(p,'cmap',[],@(s) ischar(s));
addParameter(p,'dLim',[],validNum2);
addParameter(p,'cLim',[],validNum2);
addParameter(p,'altBase',[],validNum1);
parse(p,varargin{:});

% all results will be in alphabetical order (note: a < A < b < B)
allResults = struct2cell(p.Results);
[altBase,cLim,cmap,dLim,ovrlayName] = allResults{:};

%==========================================================================
% first just load the overlay and make sure it's sensible...
% note: will be forcing overlay to be single for memory purposes...

if ischar(newOvrlay) % provided a path to the new overlay
    
    % can we load it...?
    try
        newOvrlay = MRIread(newOvrlay);
        newOvrlay = newOvrlay.vol(:);
    catch ME
        warning('Could not read overlay, no overlay added');
        fprintf('Path provided was: [%s]\n',newOvrlay);
        disp(getReport(ME,'extended','hyperlinks','on'));
        return
    end
    
else % sent data in directly
    
    try
        newOvrlay = newOvrlay(:);
    catch ME
        warning('Could not load overlay, no overlay added');
        fprintf('Data provided was: \n'); 
        whos newOvrlay;
        disp(getReport(ME,'extended','hyperlinks','on'));
        return
    end
    
end

% loaded it, does it match surface...?
if numel(newOvrlay) ~= obj.nVert
    warning('Overlay does not seem to match surface, no overlay added');
    fprintf(['(num. datapoints (%d) in loaded overlay '...
        '~= num. surface vertices (%d))\n'],...
        numel(newOvrlay),obj.nVert);
    return
end

% make it this far, must have worked!
success = true;

%==========================================================================
% find index to store new overlay in

% get current length of dataOvrlays and increment
ind = obj.nOvrlays;
ind = ind + 1;

%==========================================================================
% get mask for overlay

% find where ovrlay is zero (or alternative baseline if specified)
%
% including options for two common alternative baselines (nan, inf) 
% in case the respective functions (isnan/isinf) are faster

if ~isempty(altBase)
    maskBase = altBase;
else
    maskBase = 0;
end

if isnan(maskBase)
    mask = ~isnan(newOvrlay);
elseif isinf(maskBase)
    mask = ~isinf(maskBase);
else
    mask = newOvrlay ~= maskBase;
end

% add in data thresholding if using
if ~isempty(dLim)
    
    % if either set to nan, ignore that bound
    if isnan(dLim(1)), dLim(1) = min(newOvrlay); end
    if isnan(dLim(2)), dLim(2) = max(newOvrlay); end
    
    mask(newOvrlay < min(dLim) | newOvrlay > max(dLim)) = false;
    
end

%==========================================================================
% get colours and use them to set vertex data

% grab colors across whole matrix
tmpCols = obj.colMap.getColVals(newOvrlay(mask),cmap,cLim);

% now mask to show base color
newOvrlayCols = obj.baseOvrlay.colData;
newOvrlayCols(mask,:) = tmpCols;

% save out overlay
obj.dataOvrlay(ind).name = ovrlayName;
obj.dataOvrlay(ind).data = newOvrlay;
obj.dataOvrlay(ind).colData = newOvrlayCols;
obj.dataOvrlay(ind).mask = mask;

% save out overlay additional information
if ~isempty(cmap), obj.dataOvrlay(ind).addInfo.cmap = cmap; end
if ~isempty(dLim), obj.dataOvrlay(ind).addInfo.dLim = dLim; end
if ~isempty(cLim), obj.dataOvrlay(ind).addInfo.cLim = cLim; end
if ~isempty(altBase), obj.dataOvrlay(ind).addInfo.altBase = altBase; end

% update ovrlayNames and nOvrlays
obj.ovrlayNames = {obj.dataOvrlay(:).name};
obj.nOvrlays = numel(obj.dataOvrlay);

% and also save out as current overlay
obj.currOvrlay = obj.dataOvrlay(ind);

end



