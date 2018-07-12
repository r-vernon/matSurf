function cBack_ROI_addPnt(src,event,finalPt)

% make sure volumes loaded
f_h = getFigHandle(src);
if ~isappdata(f_h,'currVol'), return; end

% get remaining data
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% if called 'final point' but not  continuing ROI, return
if finalPt && ~strcmp(handles.addROI.String,'Cont')
    return; 
end

%--------------------------------------------------------------------------

% get point clicked, if not final point
ptClicked = [];
if ~finalPt
    ptClicked = event.IntersectionPoint; 
end

% call ROI_add with the point clicked
[vCoords,markInd,ind,newROI] = currVol.ROI_add(ptClicked,finalPt);

% display it
set(handles.brainROI,...
    'XData',vCoords(:,1),...
    'YData',vCoords(:,2),...
    'ZData',vCoords(:,3),...
    'MarkerIndices',markInd);

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
    handles.selROI.Enable = 'on';
    handles.selROI.String = currVol.roiNames;
    handles.addROI.String = 'Add';
    handles.brainPatch.ButtonDownFcn = '';
    setStatusTxt('Finished ROI');
else
    handles.selROI.Enable = 'off';
    handles.addROI.String = 'Cont';
end

drawnow;

end