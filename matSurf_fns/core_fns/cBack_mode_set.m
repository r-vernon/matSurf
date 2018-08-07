function cBack_mode_set(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

switch src.Tag
    case 'addROI'
        setStatusTxt(handles.statTxt,'In ROI drawing mode');
        handles.roiMode.Value = 1;
    otherwise
        setStatusTxt(handles.statTxt,'In data mode');
        handles.dataMode.Value = 1;
end

end