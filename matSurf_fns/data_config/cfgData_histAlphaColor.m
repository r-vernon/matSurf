function [alphaData] = cfgData_histAlphaColor(p_h,cmaps,thrPref,hInd)
% function to set color and alpha data for histogram
%
% (req.) p_h, handle to patch object
% (req.) cmaps, handle to colormaps class
% (req.) thrPref, thresholding preferences for data overlay
% (req.) hInd, histogram index, 1 if data, 2 if significance
% (ret.) alphaData, histogram alpha data, so can be modulated by global
%          transparency

%------------
% preallocate

% get data to process
data2proc = p_h.Vertices(:,1);

nE  = numel(data2proc); % number of edges
hCD = ones(nE,3); % color data
hAD = ones(nE,1); % alpha data

%----------
% alphadata

if (~thrPref.useSig && hInd == 1) || (thrPref.useSig && hInd == 2)
    
    % if thresholding mode and histogram mode match up, use thresholding to
    % set alpha data of histogram
    hAD(:) = cfgData_createThrMask(data2proc,thrPref.thrCode,thrPref.thrVals(:));
    
end

%----------
% colordata

if hInd == 1
    
    % bin the histogram data
    % (1 for normal cmap, 2 for -ve cmap)
    histBins = cfgData_binHist(data2proc,thrPref.cmapVals,thrPref.outlierMode);

    % first set set positive colormap
    hCD(histBins==1,:) = cmaps.getColVals(data2proc(histBins==1),...
        thrPref.cmapNames{1}, thrPref.cmapVals(1,:));
    
    % add second (-ve) colormap if using
    if thrPref.numCmaps == 2
        hCD(histBins==2,:) = cmaps.getColVals(data2proc(histBins==2),...
            thrPref.cmapNames{2}, thrPref.cmapVals(2,:));
    end
    
    % if in colormap clip mode, hide vals outside range
    hAD(isnan(histBins)) = 0;
    
else
    
    % if in sig. mode, set everything to heat
    hCD(:) = cmaps.getColVals(data2proc,'heat');
    
end

% mask alpha data with global transparency
% (saving out copy first so main script can change transparency)
alphaData = hAD;
if hInd == 1
    hAD = hAD * thrPref.transparency;
end

%--------------------
% update patch object

set(p_h,'FaceVertexAlphaData',hAD,'FaceVertexCData',hCD);

end