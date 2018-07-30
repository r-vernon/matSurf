function cBack_ROI_toggle(src,~)
% toggles visibility of ROIs

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% work out if ROIs should be visible or not
if src.Value == 1
    handles.brainROI.Visible = 'on';
else
    handles.brainROI.Visible = 'off';
end

end