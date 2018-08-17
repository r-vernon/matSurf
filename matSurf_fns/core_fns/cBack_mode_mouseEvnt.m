function cBack_mode_mouseEvnt(f_h,ip)
% function that deals with mouse click events, depending upon cur. mode
% Either:   click marks selected vertex with marker
% Data mode show information about current overlays
% ROI mode: add selected vertex to current or new ROI
%
% (req.) f_h, handle to main figure
% (req.) ip,  vertex intersection point where mouse click occured

% get data
currVol = getappdata(f_h,'currVol');
handles = getappdata(f_h,'handles');

% save out last selected vertex
setStatusTxt(handles.statTxt,sprintf('Selected vertex %d (Value: %.2f)',...
    ip,currVol.currOvrlay.data(ip)));

% move cone marker to selected vertex (will also update text/currVol)
surf_coneMarker(f_h,ip);

% get current mode (1. Data mode, 2, ROI mode)
if strcmp(handles.modePanel.SelectedObject.Tag,'dataMode')
    % process for data moded
else
    % pass point clicked through to add ROI point
    cBack_ROI_addPnt(f_h,ip);
end

end