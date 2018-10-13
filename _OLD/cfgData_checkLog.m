function [thrPref] = cfgData_checkLog(h,thrPref,dataMin,sigMin)
% sets various log options
%
% Note: thrPref.useLog stores log pref. for:
%   1. thresholding
%   2. thresholding graph
%   3. stats graph (histogram)

if nargin < 4
    sigMin = [];
end

%----------------------------------------
% get current mode of thr graph/histogram

% check if showing stats for data, not sig.
histShowsData = h.dStats.Value; 

if thrPref.useSig
    sigVal = 2; 
else
    sigVal = 3;
end

if histShowsData
    histVal = 3;
else
    histVal = 2;
end

%-----------------------
% check if can use log10

% check if min value in data is > 0
dataLogPos = dataMin > 0;

% check if min value in sig. data is > 0
sigLogPos = sigMin > 0;

%-----------------------------------
% update log possibility/use for thr

if (~thrPref.useSig && dataLogPos) || (thrPref.useSig && sigLogPos)
    set(h.logThr,'Value',thrPref.useLog(1),'Enable','on');
    set(h.thrLogX,'Value',thrPref.useLog(1),'Enable','on');
else
    thrPref.useLog(1) = false;
    thrPref.useLog(sigVal) = false;
    set(h.logThr,'Value',thrPref.useLog(1),'Enable','off');
    set(h.thrLogX,'Value',thrPref.useLog(1),'Enable','off');
end

% update x-axis
if thrPref.useLog(sigVal)
    h.thrAx.XScale = 'log';
else
    h.thrAx.XScale = 'linear';
end

%------------------------------------
% update log possibility/use for hist

if (histShowsData && dataLogPos) || (~histShowsData && sigLogPos)
    set(h.histLogX,'Value',thrPref.useLog(histVal),'Enable','on');
else
    thrPref.useLog(histVal) = false;
    set(h.histLogX,'Value',thrPref.useLog(histVal),'Enable','off');
end

% update x-axis
if thrPref.useLog(histVal)
    h.statsAx.XScale = 'log';
else
    h.statsAx.XScale = 'linear';
end

end