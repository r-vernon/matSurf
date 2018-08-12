function cBack_ROI_rename(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol');

% grab name of ROI to remove
oldName = handles.selROI.String{handles.selROI.Value};

% get new name for ROI, making sure there's no [e] (for edit)
newName = UI_getVarName('Enter ROI name',oldName);
newName = erase(newName,{'[e] ','[e]'});

% if clicked cancel, return
if isempty(newName), return; end

% update ROI name
success = currVol.ROI_updateName(oldName,newName);
if success
    handles.selROI.String = currVol.ROIs.name;
    setStatusTxt(handles.statTxt,'Renamed ROI');
else
    setStatusTxt(handles.statTxt,'Could not rename ROI','w',1);
end

end