function [thrPref] = cfgData_createThrPref
% function to create default settings for threshold preferences
%
% - ignZero:      whether zeros should be ignored (true) or not (false)
% - transparency: overall opacity of data overlay
% - numCmaps:     number of color maps, either 1 or 2 (if using -ve)
% - cmapNames:    names for color map(s)
% - cmapVals:     min/max for color map(s)
%                 order: [cMin1, cMax1; cMin2, cMax2]
% - outlierMode:  either 'map' or 'clip' values outside color range
% - useSig:       if data has sig. values attached, whether to use it
% - useLog4data   use log axis when showing data (nan if not poss.)
% - useLog4sig    use log axis when showing sig. values (nan if not poss.)
% - thrCode:      describes type of thresholding to use
%                 - Digit 1: (1) normal,   (2) reverse
%                 - Digit 2: (1) absolute, (2) gradient, (3) sigmoidal
%                 - Digit 3: (1) single,   (2) double
% - thrVals:      values representing the limits of the threshold
%                 order: [1a, 2a; 1b, 2b]
% - thrXLim:      x-axis limits for the threshold preview
% - histXLim:     x-axis limits for the histogram
%                 order: [data(min), data(max); sig(min), sig(max)]
% - histNBins:    number of bins for the histogram

thrPref = struct(...
    'ignZero',      true,...
    'transparency', 1,...
    'numCmaps',     uint8(1),...
    'cmapNames',    {{'heat';'cool'}},...
    'cmapVals',     nan(2,2),...
    'outlierMode',  'map',...
    'useSig',       false,...
    'useLog4data',  0,...
    'useLog4sig',   0,...
    'thrCode',      ones(3,1),...
    'thrVals',      nan(2,2),...
    'thrXLim',      nan(2,1,'single'),...
    'histXLim',     nan(2,2,'single'),...
    'histNBins',    nan(2,1,'single')...
    );

end