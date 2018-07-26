function cBack_surf_save(src,~)

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% open up save dialogue with default details
UI_saveData(currVol,currVol.surfDet.surfName,2,0,1);

end