function cBack_surf_select(src,~)

% get data
f_h = getFigHandle(src);
allVol = getappdata(f_h,'allVol');

% grab the new current volume and save it out
currVol = allVol.selVol(src.Value);
setappdata(f_h,'currVol',currVol);

% update status (sc = surface changed)
mS_stateControl(f_h,'sc');

% update status text
setStatusTxt(sprintf('Switched to %s',currVol.surfDet.surfName));

drawnow; pause(0.05);

end