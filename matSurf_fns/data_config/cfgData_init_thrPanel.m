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

%-------------------------
% set the images correctly

h.normFilt.CData = squeeze(h.thrPics(1,thrCode(2),thrCode(3),:,:,:));
h.revFilt.CData  = squeeze(h.thrPics(2,thrCode(2),thrCode(3),:,:,:));

%-----------------------------------------------
% set filter threshold ranges ([a1, a2; b1, b2])

if ~isnan(thrVals(1,1))
    set(h.f1_lEdit,'String',formatNum(thrVals(1,1)),'UserData',thrVals(1,1),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f1_lTxt.Enable = 'on';
end
if ~isnan(thrVals(2,1))
    set(h.f1_hEdit,'String',formatNum('%.2f',thrVals(2,1)),'UserData',thrVals(2,1),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f1_hTxt.Enable = 'on';
end
if ~isnan(thrVals(1,2))
    set(h.f2_lEdit,'String',formatNum('%.2f',thrVals(1,2)),'UserData',thrVals(1,2),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f2_lTxt.Enable = 'on';
end
if ~isnan(thrVals(2,2))
    set(h.f2_hEdit,'String',formatNum('%.2f',thrVals(2,2)),'UserData',thrVals(2,2),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f2_hTxt.Enable = 'on';
end

end