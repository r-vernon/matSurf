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

%--------------------------------------------------------------------------
% fill the ROI

% try to fill automatically
allVert = currVol.ROI_fill(ROI_bound);

% if more than 25% of vertices filled, likely something went wrong!
if length(allVert) > 0.25*currVol.nVert
    
    % ask user to click vertex inside ROI
    tmpMsg = msgbox(sprintf([...
        'Could not automatically fill ROI\n',...
        'Please manually select any vertex inside ROI\n\n',...
        'After selecting vertex, press ''OK'' to continue']),'ROI fill');
    
    % wait until user clicks okay to continue
    uiwait(tmpMsg);
    
    % refill ROI with selected vertex
    allVert = currVol.ROI_fill(ROI_bound,currVol.selVert);
end

%--------------------------------------------------------------------------

% get save location
[fileName,filePath] = uiputfile({'*.label';'*.*'},'Save ROI',[ROIname,'.label']);
if isequal(fileName,0), return; end % if clicked cancel
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
    setStatusTxt('Saved ROI successfully');
else
    setStatusTxt('Could not save ROI');
end

end