function cBack_ROI_delete(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

% grab name of ROI to remove
ROIname = handles.selROI.String{handles.selROI.Value};

% if it's finished, check they definitely want to remove it (no as default if hit enter)
if ~contains(ROIname,'[e]')
    reallyDel = questdlg(sprintf('Are you sure you want to delete %s?',ROIname),...
        'Delete ROI?','Yes','No','No');
    if strcmp(reallyDel,'No'), return; end
end

% try to delete selected overlay
[success,ind,vCoords] = currVol.ROI_remove(ROIname);

if success % update popupmenu and surface
    
    % switch back to data mode
    handles.dataMode.Value = 1;
    
    if ind == 0 % if deleted all ROIs
        
        % update state (rr = ROI removed)
        mS_stateControl(f_h,'rr');  
        setStatusTxt('All ROIs deleted');
        
    else % still some ROIs remaining
        
        setStatusTxt('Deleted ROI');
        
        % update select ROI text with current status
        handles.selROI.String = currVol.roiNames;
        handles.selROI.Value = ind;
        
        % update lines with new ROI vertices
        set(handles.brainROI,...
            'XData',vCoords(:,1),...
            'YData',vCoords(:,2),...
            'ZData',vCoords(:,3));
        
        % update UI elements based on current ROI state (editing or not)
        ROI_stateControl(handles);
        
    end
end

drawnow; pause(0.05);

end