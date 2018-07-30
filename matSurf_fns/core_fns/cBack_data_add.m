function cBack_data_add(src,~)

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% initialise a data overlay (TODO - get user input)
% for now just ask retinotopy or coherence
% toLoad = listdlg('ListString',{'Ret','Co'});
% switch toLoad
%     case 1
%         toRead = [pwd,'/Data/R3517/data/Phase_RH.nii.gz'];
%         cmap = 'parula';
%     case 2
%         toRead = [pwd,'/Data/R3517/data/Coher_RH.nii.gz'];
%         cmap = 'heat';
%     otherwise, return;
% end

[file,path] = uigetfile({'*.nii.gz';'*.mat';'*.*'});
toRead = fullfile(path,file);
cmap = 'parula';

% load the base overlay (curvature information, using default colours)
[success,ind] = currVol.ovrlay_add(toRead,'cmap',cmap);

if success 
    
    setStatusTxt('Loaded data overlay');
    
    % if added first overlay, update state (da = data overlay added)
    if ind == 1
        mS_stateControl(f_h,'da');
    end
    
    % update select data popupmenu
    handles.selData.String = currVol.ovrlayNames;
    handles.selData.Value = ind;
    
    % update surface (will check if showData toggle is on)
    surf_update(handles,currVol);
end

end