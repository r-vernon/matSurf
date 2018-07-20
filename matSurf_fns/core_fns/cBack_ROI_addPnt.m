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

% make sure volumes loaded
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

%--------------------------------------------------------------------------

% if called 'final point' but not  continuing ROI, return
if finalPt && ~strcmp(handles.addROI.String,'Cont')
    return; 
end

% call ROI_add with the point clicked
[vCoords,ind,newROI] = currVol.ROI_add(ptClicked);

% display it
set(handles.brainROI,...
    'XData',vCoords(:,1),...
    'YData',vCoords(:,2),...
    'ZData',vCoords(:,3));

% if first ROI, make sure ROI object is visible
if currVol.nROIs == 1
    handles.brainROI.Visible = 'on';
end

% update popup menu if needed
if newROI
    handles.selROI.String = currVol.roiNames;
    handles.selROI.Value = ind;
end

% change ROI add button to continue if drawing, or back to 'add' if
% finished. Disable select ROI option whilst drawing
if finalPt
    surf_coneMarker(f_h,currVol.ROIs(ind).selVert(1));
    set(handles.selROI,'Enable','on','String',currVol.roiNames,'Value',ind);
    handles.addROI.String = 'Add';
    handles.dataMode.Value = 1;
    setStatusTxt('Finished ROI');
else
    handles.selROI.Enable = 'off';
    handles.addROI.String = 'Cont';
end

drawnow;

end