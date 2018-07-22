function cBack_data_delete(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% grab index of data to remove
toDel = handles.selData.Value;

% try to delete selected overlay
[success,ind] = currVol.ovrlay_remove(toDel);

if success 
    if ind == 0
        
        % deleted only overlay, update state (dr = data overlay removed)
        mS_stateControl(f_h,'dr');
        setStatusTxt('All data overlays deleted');
        
        % update surface (forcing update by sending '1')
        surf_update(handles,currVol,1); 
        
    else
        
        setStatusTxt('Deleted data overlay');
        
        % update popupmenu and surface
        handles.selData.String = currVol.ovrlayNames;
        handles.selData.Value = ind;
        
        % update surface (will check if showData toggle is on)
        surf_update(handles,currVol);
    end
end

end