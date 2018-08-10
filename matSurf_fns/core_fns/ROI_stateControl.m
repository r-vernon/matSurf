function ROI_stateControl(handles)
% function that disables or enables various UI elements depending on state
% of current ROI - i.e. whether it's open for editing or not

% get current ROI name
if ischar(handles.selROI.String)
    roiName = handles.selROI.String;
else
    roiName = handles.selROI.String{handles.selROI.Value};
end

% if current ROI is open for editing (contains '[e]'),
% - change addROI option to (cont)inue
% - disable select ROI option
% - enable undo ROI option
% - enable finish ROI option
% otherwise, do opposite and set addROI to 'add'

if contains(roiName,'[e]')
    handles.addROI.String = 'Cont';
    
    handles.selROI.Enable = 'off';
    handles.impROI.Enable = 'off';
    handles.expROI.Enable = 'off';
    
    handles.undoROI.Enable = 'on';
    handles.finROI.Enable  = 'on';
else
    handles.addROI.String = 'Add';
    
    handles.selROI.Enable = 'on';
    handles.impROI.Enable = 'on';
    handles.expROI.Enable = 'on';
    
    handles.undoROI.Enable = 'off';
    handles.finROI.Enable  = 'off';
end

end