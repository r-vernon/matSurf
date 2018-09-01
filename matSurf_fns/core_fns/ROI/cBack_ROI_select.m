function cBack_ROI_select(src,~)

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% set currROI to requested ROI
currVol.currROI = src.Value;

% update UI elements based on current ROI state (editing or not)
ROI_stateControl(handles);

end