function cBack_ROI_undo(src,~)
% undo for last ROI point drawn

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% get current ROI name
ROIname = handles.selROI.String{handles.selROI.Value};

% make sure it's open for editing
if ~contains(ROIname,'[e]'), return; end

% get ROI index (should always be last ROI if editing)
ROI_ind = currVol.nROIs;

% if only one selected vertex, just delete ROI instead
if nnz(currVol.ROIs(ROI_ind).selVert) == 1
    cBack_ROI_delete(f_h);
else
    % undo the point
    [vCoords,prevInd] = currVol.ROI_undo;
    
    % move marker to previous point
    surf_coneMarker(f_h,prevInd);
    
    % display update
    set(handles.brainROI,...
        'XData',vCoords(:,1),...
        'YData',vCoords(:,2),...
        'ZData',vCoords(:,3));
    
    drawnow;
    
end

end