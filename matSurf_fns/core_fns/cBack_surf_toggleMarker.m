function cBack_surf_toggleMarker(src,~)
% toggles visibility of vertex marker

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% work out if marker should be visible or not
if src.Value == 1
    handles.markPatch.Visible = 'on';
else
    handles.markPatch.Visible = 'off';
end

end