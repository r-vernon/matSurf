function setMode_cBack(src)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

switch src.Tag
    case 'addROI'
        setStatusTxt('In ROI drawing mode');
        handles.brainPatch.ButtonDownFcn = @(src,event) ROI_addPnt_cBack(src,event,false);
    otherwise
        return
end

end