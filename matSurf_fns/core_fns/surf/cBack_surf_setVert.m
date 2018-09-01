function cBack_surf_setVert(src,~)

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% convert string to vertex number
newVert = round(str2double(src.String));

% make sure it's a valid vertex - if it's not, return last vertex 
if ~isrealnum(newVert,1,currVol.nVert)
    
    src.String = num2str(currVol.selVert);
    return
    
else
    
    % if it's valid, fake a mouse click to that vertex
    cBack_mode_mouseEvnt(f_h,newVert);
    
end

end