function cBack_data_delete(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% grab index of data to remove
toDel = handles.selData.Value;

% try to delete selected overlay
[success,ind] = currVol.ovrlay_remove(toDel);

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