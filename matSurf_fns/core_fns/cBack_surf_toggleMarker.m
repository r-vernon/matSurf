function cBack_surf_toggleMarker(src,~)
% toggles visibility of vertex marker

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% work out if marker should be visible or not
if src.Value == 1
    setStatusTxt(handles.statTxt,'Showing vertex marker');
    handles.markPatch.Visible = 'on';
else
    setStatusTxt(handles.statTxt,'Vertex marker hidden');
    handles.markPatch.Visible = 'off';
end

end