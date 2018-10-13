function cfgData_init_thrPanel(h,thrCode,thrVals)
% function to setup initial thresholding parameters
%
% (req.) h, handle to cfgData figure
% (req.) thrCode, threshold code for data overlay
% (req.) thrVals, threshold values for data overlay

%------------------------------------------------
% set the filter, filter type and # filter values

% set direction
if thrCode(1) == 1
    h.normFilt.Value = 1; % normal
else
    h.revFilt.Value = 1;  % reversed
end

% set style
if thrCode(2) == 1
    h.absFilt.Value = 1;  % absolute
elseif thrCode(2) == 2
    h.gradFilt.Value = 1; % gradient
else
    h.sigFilt.Value = 1;  % sigmoidal
end

% set number of filters
if thrCode(3) == 1
    h.oneFilt.Value = 1; % one filter
else
    h.twoFilt.Value = 1; % two filters
end

%---------------------------------
% set images/enable filter options

cfgData_config_thrPanel(h,thrCode);

%----------------------------
% set filter threshold ranges

if ~isnan(thrVals(1,1))
    set(h.xLt_edit,'String',formatNum(thrVals(1,1)),'UserData',thrVals(1,1)); 
end
if ~isnan(thrVals(1,2))
    set(h.xGt_edit,'String',formatNum(thrVals(1,2)),'UserData',thrVals(1,2)); 
end
if ~isnan(thrVals(2,1))
    set(h.xBt1_edit,'String',formatNum(thrVals(2,1)),'UserData',thrVals(2,1)); 
end
if ~isnan(thrVals(2,2))
    set(h.xBt2_edit,'String',formatNum(thrVals(2,2)),'UserData',thrVals(2,2)); 
end

end