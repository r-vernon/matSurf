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
        setStatusTxt(handles.statTxt,'All data overlays deleted');
        
        % update surface
        handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
        
    else
        
        setStatusTxt(handles.statTxt,'Deleted data overlay');
        
        % update popupmenu and surface
        handles.selData.String = currVol.ovrlayNames;
        handles.selData.Value = ind;
        
        % update surface if showing data
        if handles.togData.Value == 1
            handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
        end
    end
    
    drawnow; pause(0.05);
end

end