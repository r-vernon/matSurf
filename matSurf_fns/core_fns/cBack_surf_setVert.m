function cBack_surf_setVert(src,~)

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% convert string to vertex number
newVert = round(str2double(src.String));

% make sure it's a valid vertex - if it's not, return last vertex 
% nan will exclude most, ~isreal excludes e.g. 1+2i, isscalar excludes
% cases where passed e.g {'1','2'}, then just check range
if isnan(newVert) || ~isreal(newVert) || ~isscalar(newVert) || ...
        newVert < 0 || newVert > currVol.nVert
    
    src.String = num2str(currVol.selVert);
    return
    
else
    
    % if it's valid, fake a mouse click to that vertex
    cBack_mode_mouseEvnt(f_h,newVert);
    
end

end