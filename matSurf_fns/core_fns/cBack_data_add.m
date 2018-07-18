function cBack_data_add(src,~)

% make sure volumes loaded
f_h = getFigHandle(src);
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% initialise a data overlay (TODO - get user input)
% for now just ask retinotopy or coherence
toLoad = listdlg('ListString',{'Ret','Co'});
switch toLoad
    case 1
        toRead = [pwd,'/Data/R3517/data/Phase_RH.nii.gz'];
        cmap = 'parula';
    case 2
        toRead = [pwd,'/Data/R3517/data/Coher_RH.nii.gz'];
        cmap = 'heat';
    otherwise, return;
end

% load the base overlay (curvature information, using default colours)
[success,ind] = currVol.ovrlay_add(toRead,'cmap',cmap);

if success % update popupmenu and surface, plus flag
    handles.selData.String = currVol.ovrlayNames;
    handles.selData.Value = ind;
    surf_update(handles,currVol);
end

end