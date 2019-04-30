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
    setStatusTxt(handles.statTxt,'Can''t save unfinished ROI','w');
    return
end

% get ROI index
ind = find(strcmp(currVol.ROIs.name,ROIname),1);

% get the boundary points for the ROI we want to save
ROI_bound = currVol.ROIs.allVert{ind};

% remove nans
ROI_bound(isnan(ROI_bound)) = [];

%--------------------------------------------------------------------------
% fill the ROI

% try to fill automatically
allVert = currVol.ROI_fill(ROI_bound);

% if > 50% of vertices filled, likely filled outside ROI so invert selection
if numel(allVert) > 0.5*currVol.nVert
    
    % create temporary logical array, initially include all vertices
    tmp = true(currVol.nVert,1);
    
    % remove falsely selected vertices, then add bound vertices back in
    tmp(allVert) = 0;
    tmp(ROI_bound) = 1;
    
    % save out as new allVert
    allVert = find(tmp);
end

%--------------------------------------------------------------------------
% temporarily highlight selected region

% get all vertex coords
allCoords = currVol.TR.Points(allVert,:);

tmpPlot = line(handles.xForm,allCoords(:,1),allCoords(:,2),...
    allCoords(:,3),'Color','red','LineStyle','none','Marker','.');
drawnow;

%--------------------------------------------------------------------------
% get save location

[fileName,filePath] = uiputfile({'*.label';'*.*'},'Save ROI',[ROIname,'.label']);

% if clicked cancel, just delete highlighted ROI and return
if isequal(fileName,0)
    delete(tmpPlot);
    drawnow; pause(0.05);
    return;
end

% set full filename and subject
fileName = fullfile(filePath,fileName);
subject = currVol.surfDet.subject;

%--------------------------------------------------------------------------
% now set vertex details

% undo the centroid shift in allCoords
allCoords = bsxfun(@plus,allCoords,currVol.centroid);

% undo +1 on vertices so back to zero indexing
allVert = allVert - 1;

%--------------------------------------------------------------------------
% save out the ROI

success = write_label(allVert, allCoords, [], fileName, subject);

if success
    setStatusTxt(handles.statTxt,'Saved ROI successfully');
else
    setStatusTxt(handles.statTxt,'Could not save ROI','w');
end

% delete temporary plot
delete(tmpPlot);
drawnow; pause(0.05);

end