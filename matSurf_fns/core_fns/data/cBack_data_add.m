function cBack_data_add(src,~)

% get data
f_h = getFigHandle(src);
cmaps   = getappdata(f_h,'cmaps');
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% create filter for find file dialogue
fileFilt = {['*',currVol.surfDet.hemi,'*.nii.gz'];'*.nii.gz';'*.mat';'*.*'};

[file,path] = uigetfile(fileFilt,'MultiSelect','on');
toRead = fullfile(path,file);

% count number of scans to add
if iscell(toRead)
    n2add = length(toRead);
else
    n2add = 1;
end

% set flag to check if any overlay loaded
ovrlayAdded = false;

% loop over every overlay requested
for currOvrlay = 1:n2add
    
    % get the name
    if iscell(toRead)
        cName = toRead{currOvrlay};
    else
        cName = toRead;
    end
    
    % make sure file exists
    if ~exist(cName,'file'), continue; end

    % choose colormap
    colMaps = {cmaps.colMaps.name};
    [ind,success] = listdlg('PromptString','Select colormap','ListString',...
        colMaps,'SelectionMode','single');
    if ~success, continue; end

    % load the overlay (curvature information, using default colours)
    [success,ind] = currVol.ovrlay_add(cName,'cmap',colMaps{ind});
    if ~success, continue; end
    
    % if added first overlay, update state (da = data overlay added)
    if ind ==1, mS_stateControl(f_h,'da'); end
    
    % if made it this far, at least one overlay added
    ovrlayAdded = true;
end

% if at least one overlay added, update UI
if ovrlayAdded 
    
    setStatusTxt(handles.statTxt,'Loaded data overlay(s)');
    
    % update select data popupmenu
    handles.selData.String = currVol.ovrlayNames;
    handles.selData.Value = ind;
    
    % update surface if showing data
    if handles.togData.Value == 1
        handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
    end
    
    drawnow; pause(0.05);
end

end