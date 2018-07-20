function cBack_ROI_delete(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');
currVol = getappdata(f_h,'currVol'); 

if currVol.nROIs == 0, return; end

% grab name of ROI to remove
ROIname = handles.selROI.String{handles.selROI.Value};

% try to delete selected overlay
[success,ind,vCoords] = currVol.ROI_remove(ROIname);

if success % update popupmenu and surface
    
    % switch back to data mode
    handles.dataMode.Value = 1;
    
    if ind == 0 % if deleted all ROIs
        
        % reset status to normal
        handles.addROI.String = 'Add';
        handles.selROI.Enable = 'on';
        handles.selROI.String = 'Select ROI';
        handles.selROI.Value = 1;
        set(handles.brainROI,'XData',[],'YData',[],'ZData',[]);
        
    else % still some ROIs remaining
        
        % if next selected ROI is open for editing (contains '[e]'),
        % disable select ROI option and set to continue, otherwise reset
        if contains(currVol.roiNames{ind},'[e]')
            handles.addROI.String = 'Cont';
            handles.selROI.Enable = 'off';
        else
            handles.addROI.String = 'Add';
            handles.selROI.Enable = 'on';
        end
        
        % update select ROI text with current status
        handles.selROI.String = currVol.roiNames;
        handles.selROI.Value = ind;
        
        % update lines with new ROI vertices
        set(handles.brainROI,'XData',vCoords(:,1),...
            'YData',vCoords(:,2),'ZData',vCoords(:,3));
    end
end

drawnow;

end