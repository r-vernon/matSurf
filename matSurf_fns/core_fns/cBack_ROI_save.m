function cBack_ROI_save(src,~)

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol');
handles = getappdata(f_h,'handles');

%--------------------------------------------------------------------------
% first just get all ROI details, subject and save location

% get current ROI name
ROIname = handles.selROI.String{handles.selROI.Value};

% make sure it's finished
if contains(ROIname,'[e]')
    setStatusTxt('Can''t save unfinished ROI');
    return
end



% get ROI index
ROI_ind = find(strcmpi({currVol.ROIs.name},ROIname),1);

% get the boundary points for the ROI we want to save
ROI_bound = currVol.ROIs(ROI_ind).allVert;

% fill the ROI
allVert = currVol.ROI_fill(ROI_bound);

% get save location
[fileName,filePath] = uiputfile({'*.label';'*.*'},'Save ROI',[ROIname,'.label']);
if fileName == 0, return; end % if clicked cancel
fileName = fullfile(filePath,fileName);

% subject
subject = currVol.surfDet.subject;

%--------------------------------------------------------------------------
% now get vertex details

% get all vertex coords
allCoords = currVol.TR.Points(allVert,:);

% undo the centroid shift
allCoords = bsxfun(@plus,allCoords,currVol.centroid);

% undo +1 on vertices so back to zero indexing
allVert = allVert - 1;

%--------------------------------------------------------------------------
% save out the ROI

success = write_label(allVert, allCoords, [], fileName, subject);

if success
    setStatusTxt('saved ROI successfully');
else
    setStatusTxt('could not save ROI');
end

end