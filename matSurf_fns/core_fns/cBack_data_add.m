function cBack_data_add(src,~)

% get data
f_h = getFigHandle(src);
cmaps   = getappdata(f_h,'cmaps');
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% create filter for find file dialogue
fileFilt = {['*',currVol.surfDet.hemi,'*.nii.gz'];'*.nii.gz';'*.mat';'*.*'};

[file,path] = uigetfile(fileFilt);
toRead = fullfile(path,file);
if ~exist(toRead,'file'), return; end

% choose colormap
colMaps = {cmaps.colMaps.name};
[ind,success] = listdlg('PromptString','Select colormap','ListString',...
    colMaps,'SelectionMode','single');
if ~success, return; end

% load the base overlay (curvature information, using default colours)
[success,ind] = currVol.ovrlay_add(toRead,'cmap',colMaps{ind});

if success 
    
    setStatusTxt(handles.statTxt,'Loaded data overlay');
    
    % if added first overlay, update state (da = data overlay added)
    if ind == 1
        mS_stateControl(f_h,'da');
    end
    
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