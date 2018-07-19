function cBack_ROI_delete(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

if currVol.nROIs == 0, return; end

% grab index of ROI to remove
toDel = handles.selROI.Value;

% try to delete selected overlay
[success,ind] = currVol.ROI_remove(toDel);

if success % update popupmenu and surface
    if ind == 0
        handles.selData.String = 'Select Data';
        handles.selData.Value = 1;
        surf_update(handles,currVol,1); % forcing update by sending '1'
    else
        handles.selData.String = currVol.ovrlayNames;
        handles.selData.Value = ind;
        surf_update(handles,currVol);
    end
end

end