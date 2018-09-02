function [dataBins] = cfgData_binHist(data2proc,binEdges,outlierMode)
% function to bin histogram data, either to pos. colormap (1), neg.
% colormap (2) or if using clip mode, outside colormap (nan)
% 
% (req.) data2proc, data to process
% (req.) binEdges, the bin edges (min/max for colormap(s))
% (req.) outlierMode, how outliers are dealt with - (m)ap or (c)lip

% initially preallocate everything to cmap 1 (+ve)
dataBins = ones(size(data2proc),'uint8');

% remove nans in binEdges (deleting 2nd colmap if both edges not set)
if any(isnan(binEdges(2,:))), binEdges(2,:) = nan; end
binEdges(isnan(binEdges)) = [];

% make sure there's either 2 or 4 bin edges
nBins = numel(binEdges);
if nBins ~= 2 || nBins ~= 4
    return
end

% work out whether 1 or 2 colormaps
if nBins == 2 % one colormap
    
    % if in map mode (outlierMode(1) = 'm'), everything should just be set
    % to cmap 1, which is already true!
    
    if strcmpi(outlierMode(1),'c') % clip mode
        
        % set outliers set to nan
        dataBins(data2proc < binEdges(1) | data2proc > binEdges(2)) = nan;
        
    end
    
else % two colormaps
    
    % sort the bins
    binEdges = sort(binEdges(:));
    
    % by default only left side of bin edges are included, add tiny
    % amount to bin edges so right side included for main bins
    binEdges([2,4]) = binEdges([2,4]) + eps(binEdges([2,4]));
    
    % make sure binEdge 2 is less than binEdge 3
    if binEdges(2) >= binEdges(3)
        binEdges(2) = binEdges(3) - eps(binEdges(3));
    end
    
    % bin the data - will be 5 bins: <neg, neg, mid, pos, >pos
    binnedData = discretize(data2proc,[-inf;binEdges;inf]);
    
    % set datapoints in 2nd bin (neg. colormap) to cmap 2
    dataBins(binnedData==2) = 2;
    
    % allocate outlier data (bins 1,3,5) to colormaps depending upon mode
    if strcmpi(outlierMode(1),'m') % map mode
        
        % map extreme neg. outliers (bin 1) to -ve colormap
        dataBins(binnedData == 1) = 2;
        
        % check for any middle values (bin 3)
        midVals = find(binnedData == 3);
        
        % if midVals exist, allocate to colormaps
        if ~isempty(midVals)
            
            % if middle values straddle zero, use zero as midWayPnt,
            % otherwise take average
            if binEdges(2) <= 0 && binEdges(3) >= 0
                midWayPnt = 0;
            else
                midWayPnt = mean(binEdges(2:3));
            end
            
            % set data to left of midway point to -ve colormap
            data2cmap2 = data2proc(midVals) < midWayPnt;
            dataBins(midVals(data2cmap2)) = 2;
            
        end
        
    else % clip mode
        
        % if clip mode, just set anything outside main bins to nan, easy!
        dataBins(binnedData~=2 | binnedData~=4) = nan;

    end
end

end