function cBack_surf_delete(src,~)

% get data
f_h = getFigHandle(src);
allVol = getappdata(f_h,'allVol');
handles = getappdata(f_h,'handles');