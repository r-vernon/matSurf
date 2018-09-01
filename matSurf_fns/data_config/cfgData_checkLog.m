function [thrPref] = cfgData_checkLog(h,thrPref,dataMin,sigMin)

if nargin < 4
    sigMin = [];
end

%----------------------------------------
% get current mode of thr graph/histogram

if thrPref.useSig
    dataSig = false;
    sigVal = 2;
else
    dataSig = true;
    sigVal = 3;
end

if h.dStats.Value == 1
    dataHist = true;
    histVal = 3;
else
    dataHist = false;
    histVal = 2;
end

%-----------------------
% check if can use log10

% check if min value in data is >= 0
dataLogPos = dataMin >= 0;

% check if min value in sig. data is >= 0
sigLogPos = sigMin >= 0;

%-----------------------------------
% update log possibility/use for thr

if (dataSig && dataLogPos) || (~dataSig && sigLogPos)
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

if (dataHist && dataLogPos) || (~dataHist && sigLogPos)
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