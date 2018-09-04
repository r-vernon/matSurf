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
if thrPref.useLog(2)
    minMax = log10(minMax);
    thrX = logspace(minMax(1),minMax(2),1e5)';
else
    thrX = linspace(minMax(1),minMax(2),1e5)';
end

% get y vals
thrY = cfgData_createThrMask(thrX,thrPref.thrCode,thrVals(:));

%---------------------
% set filter line data

% set x limits to auto (can override later if needed)
set(h.thrAx,'XLimMode','auto');

% plot main line
set(h.thrPlot,'XData',thrX,'YData',thrY);

% 1a
if ~isnan(thrVals(1))
    set(h.thrFilt_1a,'XData',[thrVals(1),thrVals(1)],'YData',[-0.1,1.1]); 
end

% 1b
if ~isnan(thrVals(2))
    set(h.thrFilt_2a,'XData',[thrVals(2),thrVals(2)],'YData',[-0.1,1.1]); 
end

% 2a
if ~isnan(thrVals(3))
    set(h.thrFilt_1b,'XData',[thrVals(3),thrVals(3)],'YData',[-0.1,1.1]); 
end

% 2b
if ~isnan(thrVals(4))
    set(h.thrFilt_2b,'XData',[thrVals(4),thrVals(4)],'YData',[-0.1,1.1]); 
end

% draw to make sure everything rendered/set
drawnow;

% x/y limits back to manual
set(h.thrAx,'XLimMode','manual');

%------------------
% deal with XLimits

% set or get XLimits
if any(isnan(thrPref.thrXLim))
    thrPref.thrXLim(:) = h.thrAx.XLim;
else
    h.thrAx.XLim = thrPref.thrXLim;
end

% set background image limits
set(h.thrAxBG,'XData',h.thrAx.XLim,'YData',h.thrAx.YLim);

% set the XLim
set(h.thrXLim1Edit,'String',formatNum(h.thrAx.XLim(1)),'UserData',h.thrAx.XLim(1));
set(h.thrXLim2Edit,'String',formatNum(h.thrAx.XLim(2)),'UserData',h.thrAx.XLim(2));    

end