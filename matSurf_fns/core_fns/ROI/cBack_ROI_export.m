function cBack_ROI_export(src,~)
% function to export an ROI

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol');

% grab ROIs
allROIs = currVol.ROIs;

% remove any unfinished ROIs
allROIs(contains(allROIs.name,'[e]')) = [];

% make sure there's some empty ROIs to save
if isempty(allROIs)
    setStatusTxt(f_h,'No finished ROIs to remove','w');
    return;
end

% remove visible field as not relevant outside class
allROIs = rmfield(allROIs,'visible');

% put all into structure with ROIs plus surface details and save time
s = struct('ROIs',allROIs,'surfDet',currVol.surfDet,...
    'saveTime',datetime('now','Format','d-MMM-y'));

% construct a plausible name
saveName = [currVol.surfDet.subject,'_',currVol.surfDet.hemi,'_ROIs'];

% pass through to save dialogue
[fileOrVar,dataLoc] = UI_saveData(saveName);

% save the data (if didn't cancel)
if ~isempty(fileOrVar)
    saveData(s,fileOrVar,dataLoc,saveName,0)
    drawnow; pause(0.05);
end

end