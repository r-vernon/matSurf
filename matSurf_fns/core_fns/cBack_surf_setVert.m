function cBack_surf_setVert(src,~)

% make sure they've entered a valid number
try
    newVert = round(str2double(src.String));
catch
    % if not valid number, just wipe it and return
    src.String = '';
    return
end

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% make sure number is within valid range
if isnan(newVert) || newVert < 0 || newVert > currVol.nVert
    src.String = '';
    return
else
    % if it's valid, fake a mouse click to that vertex
    cBack_mode_mouseEvnt(f_h,newVert);
end

end