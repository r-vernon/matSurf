function cBack_mode_mouseEvnt(f_h,ip)
% function that deals with mouse click events, depending upon cur. mode
% Either:   click marks selected vertex with marker
% Data mode show information about current overlays
% ROI mode: add selected vertex to current or new ROI
%
% (req.) f_h, handle to main figure
% (req.) ip,  vertex intersection point where mouse click occured

% get data
handles = getappdata(f_h,'handles');

% get current mode (1. Data mode, 2, ROI mode)
if strcmp(handles.modePanel.SelectedObject.Tag,'dataMode')
    currMode = 1;
else
    currMode = 2;
end

% In either mode, show info about vertex clicked, do that now
setStatusTxt(sprintf('Selected vertex %d',ip));
surf_coneMarker(f_h,ip);