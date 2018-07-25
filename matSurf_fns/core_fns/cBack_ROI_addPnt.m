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
[vCoords,ind,newROI] = currVol.ROI_add(ptClicked);

% display it
set(handles.brainROI,...
    'XData',vCoords(:,1),...
    'YData',vCoords(:,2),...
    'ZData',vCoords(:,3));

% if first ROI, set state accordingly (ra = ROI added)
if currVol.nROIs == 1
    mS_stateControl(f_h,'ra');
end

% update popup menu if needed
if newROI
    handles.selROI.String = currVol.roiNames;
    handles.selROI.Value  = ind;
end

% change ROI add button to continue if drawing, or back to 'add' if finished
% Disable select ROI option whilst drawing
% Disable finish ROI option whilst not drawing
if finalPt
    
    % update ROI name
    oldName = currVol.ROIs(ind).name;
    newName = UI_getVarName('Enter ROI name',oldName);
    currVol.ROI_updateName(oldName,newName);
    
    % move surface marker
    surf_coneMarker(f_h,currVol.ROIs(ind).selVert(1));
    
    % enable/disable UI options
    set(handles.selROI,'Enable','on','String',currVol.roiNames,'Value',ind);
    handles.finROI.Enable = 'off';
    handles.addROI.String = 'Add';
    handles.dataMode.Value = 1;
    
    setStatusTxt('Finished ROI');
else
    % enable/disable UI options
    handles.selROI.Enable = 'off';
    handles.finROI.Enable = 'on';
    handles.addROI.String = 'Cont';
end

drawnow;

end