function cBack_data_select(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% set currOvrlay to requested data
[success] = currVol.ovrlay_set(src.Value);

if success
    setStatusTxt(handles.statTxt,'Changed data overlay');
    
    % update surface if showing data
    if handles.togData.Value == 1
        handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
    end
    
    drawnow;
end

end