function cBack_setMode(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

switch src.Tag
    case 'addROI'
        setStatusTxt('In ROI drawing mode');
        handles.brainPatch.ButtonDownFcn = @ROI_addPnt_cBack;
    otherwise
        return
end

end