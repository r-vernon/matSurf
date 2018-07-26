function cBack_ROI_export(src,~)
% function to export an ROI

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol');

% grab ROIs
s.ROIs = currVol.ROIs;

% remove any unfinished ROIs
s.ROIs(contains({s.ROIs.name},'[e]')) = [];

% make sure there's some empty ROIs to save
if isempty(s)
    setStatusTxt('No finished ROIs to remove');
    return;
end

% remove visible field as not relevant outside class
s = rmfield(s.ROIs,'visible');

% add surface details and save time to ROI structure
s.surfDet = currVol.surfDet;
s.saveTime = datetime('now','Format','d-MMM-y');

% construct a plausible name
saveName = [currVol.surfDet.subject,'_',currVol.surfDet.hemi,'_ROIs'];

% pass through to save dialogue
UI_saveData(s,saveName);
drawnow; pause(0.05);

end