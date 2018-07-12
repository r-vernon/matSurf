function data_toggle_cBack(src)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

if src.Value == 0 % don't show data (sending '0' requests base)
    
    [success] = currVol.ovrlay_set(0);
    
else % set currOvrlay to currently highlighted data
    
    currData = handles.selData.Value;
    [success] = currVol.ovrlay_set(currData);
    
end

if success
    surf_update(handles,currVol,1); % forcing update by sending '1'
end

end