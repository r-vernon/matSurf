function colVals = getColVals(obj,dataVals,cmap,cLim)
% function to get colormap vals corresponding to dataVals
%
% (req.) dataVals, array of data wanting colormap for
% (opt.) cmap, specifies colormap to use (uses default if none
%        provided)
% (opt.) cLim, format [lower bound, upper bound], constrains colors 
%        between bounds e.g. to maximise viewable range - set either to nan 
%        to ignore that bound, i.e. [0,nan] constrains to [0,max(dataVals)]
% (ret.) colVals - colours to use, ranging 0:1, in array
%        sized [size(dataVals),3]

% deal with optional inputs
if nargin < 3 || isempty(cmap)
    cmap = obj.def_colMap;
end
if nargin < 4
    cLim = [];
end

% make sure dataVals is in vector format
if isvector(dataVals)
    dataDim = length(dataVals);
else
    dataDim = size(dataVals);
    dataVals = dataVals(:);
end

% grab colormap ind
cmapInd = find_cmap(obj,cmap);

% scale dataVals to 0:1, taking into account ulBound
if ~isempty(cLim)
    
    % if either set to nan, ignore that bound
    if isnan(cLim(1)), cLim(1) = min(dataVals); end
    if isnan(cLim(2)), cLim(2) = max(dataVals); end
    
    dataVals(dataVals < min(cLim)) = min(cLim);
    dataVals(dataVals > max(cLim)) = max(cLim);
    
end
dataVals = setRange(dataVals,[0,1]);

% grab color values to return
colVals = interp1(...
    obj.x,...
    obj.colMaps(cmapInd).cmap,...
    dataVals);

% reshape to original dimensions
colVals = reshape(colVals,[dataDim,3]);

end