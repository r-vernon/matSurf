function data_select_cBack(src)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% set currOvrlay to requested data
[success] = currVol.ovrlay_set(src.Value);

if success
    surf_update(handles,currVol);  
end

end