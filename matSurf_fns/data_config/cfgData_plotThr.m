function [thrPref] = cfgData_plotThr(minMax,h,thrPref)
% function to create a histogram to represent data
% - actually using patch objects as gives more control over results
%   (and bar graph CData only provided in Matlab 2017+...)
%
% (req.) minMax, min and max values of x values in thr. plot
% (req.) h, handle to cfgData figure
% (req.) thrPref, thresholding preferences for data overlay
% (ret.) thrPref, updated thresholding preferences

% extract thrVals for more concise code
thrVals = thrPref.thrVals;

%-----------------------
% get x, y data for plot

% get x vals
thrX = linspace(minMax(1),minMax(2),1e5)';

% get y vals
thrY = cfgData_createThrMask(thrX,thrPref.thrCode,thrVals(:));

% plot results
set(h.thrPlot,'XData',thrX,'YData',thrY);

%------------------
% deal with XLimits

% set or get XLimits
if any(isnan(thrPref.thrXLim))
    thrPref.thrXLim(:) = h.thrAx.XLim;
else
    h.thrAx.XLim = thrPref.thrXLim;
end

% set the XLim
set(h.thrXLim1Edit,'String',formatNum(h.thrAx.XLim(1)),'UserData',h.thrAx.XLim(1));
set(h.thrXLim2Edit,'String',formatNum(h.thrAx.XLim(2)),'UserData',h.thrAx.XLim(2));    

%---------------------
% set filter line data

% a1
if ~isnan(thrVals(1))
    set(h.thrFilt_a1,'XData',[thrVals(1),thrVals(1)],'YData',[-0.05,1.05]); 
end

% b1
if ~isnan(thrVals(2))
    set(h.thrFilt_a2,'XData',[thrVals(2),thrVals(2)],'YData',[-0.05,1.05]); 
end

% a2
if ~isnan(thrVals(3))
    set(h.thrFilt_b1,'XData',[thrVals(3),thrVals(3)],'YData',[-0.05,1.05]); 
end

% b2
if ~isnan(thrVals(4))
    set(h.thrFilt_b2,'XData',[thrVals(4),thrVals(4)],'YData',[-0.05,1.05]); 
end

end