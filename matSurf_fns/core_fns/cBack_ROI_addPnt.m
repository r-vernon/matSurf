function cBack_ROI_addPnt(src,ptClicked)

% check if source was adding point, or finishing point
if strcmp(src.Tag,'finROI')
    f_h = getFigHandle(src);
    finalPt = true;
    ptClicked = [];
else
    f_h = src;
    finalPt = false;
end

% get remaining data
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

%--------------------------------------------------------------------------

% call ROI_add with the point clicked
[vCoords,newROI] = currVol.ROI_add(ptClicked);

% get the index of the current ROI
ind = currVol.currROI;

% display it
set(handles.brainROI,...
    'XData',vCoords(:,1),...
    'YData',vCoords(:,2),...
    'ZData',vCoords(:,3));

% if it's a new ROI, check if it's first ROI, and update ROI names
if newROI
    
    % if first ROI, set state accordingly (ra = ROI added)
    if currVol.nROIs == 1
        mS_stateControl(f_h,'ra');
    end
    
    % update popup menu
    handles.selROI.String = currVol.ROIs.name;
    handles.selROI.Value  = ind;
end

if finalPt
    
    % move surface marker
    surf_coneMarker(f_h,currVol.ROIs.selVert{ind}(1));
    
    % get new name for ROI, making sure there's no [e] (for edit)
    oldName = currVol.ROIs.name{ind};
    newName = UI_getVarName('Enter ROI name',erase(oldName,{'[e] ','[e]'}));
    newName = erase(newName,{'[e] ','[e]'});
    
    % if clicked cancel, undo added point and return
    if isempty(newName)
        cBack_ROI_undo(f_h);
        return;
    else
        % mark ROI as finished
        currVol.ROI_fin;
    end
    
    % update ROI name 
    success = currVol.ROI_updateName(oldName,newName);
    if success
        set(handles.selROI,'String',currVol.ROIs.name,'Value',ind);
    else
        setStatusTxt(handles.statTxt,'Could not rename ROI','w',1);
    end

    % switch back to data mode 
    handles.dataMode.Value = 1;
    
    setStatusTxt(handles.statTxt,'Finished ROI');
end

% update UI elements based on current ROI state (editing or not)
ROI_stateControl(handles);

drawnow; 

end