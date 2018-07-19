function cBack_setMode(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

switch src.Tag
    case 'addROI'
        setStatusTxt('In ROI drawing mode');
        handles.roiMode.Value = 1;
    otherwise
        setStatusTxt('In data mode');
        handles.dataMode.Value = 1;
end

end