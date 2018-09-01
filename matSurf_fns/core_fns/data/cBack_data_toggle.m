function cBack_data_toggle(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

if src.Value == 0 % don't show data (sending '0' requests base)
    
    msg = 'Data overlay hidden';
    [success] = currVol.ovrlay_set(0);
    
else % set currOvrlay to currently highlighted data
    
    msg = 'Showing data overlay';
    currData = handles.selData.Value;
    [success] = currVol.ovrlay_set(currData);
    
end

if success
    setStatusTxt(handles.statTxt,msg);
    
    % update surface
    handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
    
    drawnow;
end

end