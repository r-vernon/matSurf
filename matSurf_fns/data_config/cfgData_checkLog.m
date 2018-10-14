function [thrPref] = cfgData_checkLog(h,thrPref,dataMin,sigMin)

%----------------------------------
% check if can use log for data/sig
% (nan implies not possible)

% check if min value in data is <= 0
if dataMin <= 0
    thrPref.useLog4data = nan;
end

% check if min value in sig. data is <= 0
if nargin < 4 || sigMin <= 0
    thrPref.useLog4sig = nan;
end

%------------------------------------------
% create enter function for boxes if needed

enterFcn = @(fig,~) set(fig, 'Pointer', 'hand');

%-----------------------------------
% update log possibility/use for thr

% if thr. graph in data mode...
if h.dThr.Value == 1 
    thrUseLog = thrPref.useLog4data;
else
    thrUseLog = thrPref.useLog4sig;
end

% update threshold log status based on thrUseLog
if isnan(thrUseLog)
    h.thrAx.XScale = 'linear';
    set(h.thrXLog,'Value',0,'Enable','off');
    iptSetPointerBehavior(h.thrXLog, '');
else
    set(h.thrXLog,'Value',thrUseLog,'Enable','on');
    
    if isempty(iptGetPointerBehavior(h.thrXLog))
        iptSetPointerBehavior(h.thrXLog, enterFcn);
    end
    
    if thrUseLog == 0
        h.thrAx.XScale = 'linear';
    else
        h.thrAx.XScale = 'log';
    end
end

%------------------------------------
% update log possibility/use for hist

% if histogram in data mode...
if h.dStats.Value == 1 
    histUseLog = thrPref.useLog4data;
else
    histUseLog = thrPref.useLog4sig;
end

% update histogram log status based on histUseLog
if isnan(histUseLog)
    h.statsAx.XScale = 'linear';
    set(h.histXLog,'Value',0,'Enable','off');
    iptSetPointerBehavior(h.histXLog, '');
else
    set(h.histXLog,'Value',histUseLog,'Enable','on');
    
    if isempty(iptGetPointerBehavior(h.histXLog))
        iptSetPointerBehavior(h.histXLog, enterFcn);
    end
    
    if histUseLog == 0
        h.statsAx.XScale = 'linear';
    else
        h.statsAx.XScale = 'log';
    end
end

end