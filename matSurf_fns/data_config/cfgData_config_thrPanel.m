function cfgData_config_thrPanel(h,thrCode)
% function to configure the thresholding panel, set images correctly and
% enable/disable correct ranges depending upon threshold code
%
% (req.) h, handle to cfgData figure
% (req.) thrCode, threshold code for data overlay

%-------------------------
% set the images correctly

h.normFilt.CData = squeeze(h.thrPics(1,thrCode(2),thrCode(3),:,:,:));
h.revFilt.CData  = squeeze(h.thrPics(2,thrCode(2),thrCode(3),:,:,:));

%-----------------------------------------
% work out which filters should be enabled

% if not absolute gradient, filt 1. high (1b) enabled
if thrCode(2) ~= 1
    set(h.f1_hEdit,'Enable','on','UIContextMenu',h.cpMenu);
    h.f1_hTxt.Enable = 'on';
else
    set(h.f1_hEdit,'String','nan','Enable','off','UIContextMenu','');
    h.f1_hTxt.Enable = 'off';
end

if thrCode(3) == 1 % if one filter
    
    % values for filter 2 (2a/2b) disabled
    set([h.f2_lEdit,h.f2_hEdit],'String','nan','Enable','off','UIContextMenu','');
    h.f2_lTxt.Enable = 'off';
    h.f2_hTxt.Enable = 'off';
    
else % two filters
    
    % filter 2 low (2a) enabled
    set(h.f2_lEdit,'Enable','on','UIContextMenu',h.cpMenu);
    h.f2_lTxt.Enable = 'on';
    
    % if not absolute gradient, filt 2. high (2b) enabled
    if thrCode(2) ~= 1
        set(h.f2_hEdit,'Enable','on','UIContextMenu',h.cpMenu);
        h.f2_hTxt.Enable = 'on';
    else
        set(h.f2_hEdit,'String','nan','Enable','off','UIContextMenu','');
        h.f2_hTxt.Enable = 'off';
    end
end

end