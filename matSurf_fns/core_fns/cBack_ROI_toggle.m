function cBack_ROI_toggle(src,~)
% toggles visibility of ROIs

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% work out if ROIs should be visible or not
if src.Value == 1
    setStatusTxt(handles.statTxt,'Showing ROIs');
    handles.brainROI.Visible = 'on';
else
    setStatusTxt(handles.statTxt,'ROIs hidden');
    handles.brainROI.Visible = 'off';
end

end