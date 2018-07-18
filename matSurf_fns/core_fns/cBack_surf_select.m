function cBack_surf_select(src,~)

% get data
f_h = getFigHandle(src);
allVol = getappdata(f_h,'allVol');
camCont = getappdata(f_h,'camCont');
handles = getappdata(f_h,'handles');

% grab the new current volume
nCurrVol = allVol.selVol(src.Value);

% set xyz limits for axis
xyzLim = [-1,1] * nCurrVol.xyzLim;
set(handles.brainAx,'XLim',xyzLim,'YLim',xyzLim,'ZLim',xyzLim);

% set the camera position to old position
set(handles.brainAx,nCurrVol.cam.NA,nCurrVol.VA_cur);
handles.xForm.Matrix = qRotMat(nCurrVol.q_cur);

% make sure camCont is in 'reset' state
camCont.mMoved = false;
camCont.clPatch = false;
camCont.qForm = nCurrVol.q_cur;

%--------------------------------------------------------------------------
% update data and ROI windows % TODO - put this in update fcn

% data overlays
if nCurrVol.nOvrlays == 0
    % if no overlays, just set everything to defaults
    handles.selData.String = 'Select Data';
    handles.selData.Value = 1;
    handles.togData.Value = 1;
else
    % get ind of curr overlay
    cOvrlay = nCurrVol.ovrlay_find(nCurrVol.currOvrlay.name);
    handles.selData.String = nCurrVol.ovrlayNames;
    if cOvrlay == 0
        % current overlay is base, so set data select to first overlay and
        % make it hidden
        handles.selData.Value = 1;
        handles.togData.Value = 0;       
    else
        % show the current loaded overlay
        handles.selData.Value = cOvrlay;
        handles.togData.Value = 1;
    end
end
    
% ROIs
handles.selROI.Value = 1;
if nCurrVol.nROIs == 0
    % if no overlays, just set everything to defaults
    handles.selROI.String = 'Select ROI';
    handles.togROI.Value = 1;
else
    handles.selROI.String = nCurrVol.roiNames;
    handles.togROI.Value = 0;
end

% make sure no old ROIs loaded
set(handles.brainROI,'XData',[],'YData',[],'ZData',[]);

%--------------------------------------------------------------------------

% display new current volume
set(handles.brainPatch,...
    'vertices',nCurrVol.TR.Points,...
    'faces',nCurrVol.TR.ConnectivityList,...
    'FaceVertexCData',nCurrVol.currOvrlay.colData,...
    'VertexNormals',vertexNormal(nCurrVol.TR),...
    'FaceNormals',faceNormal(nCurrVol.TR));

% make sure no markers visible
set(handles.markPatch,'faces',[],'vertices',[]);

% update title
handles.matSurfFig.Name = ['matSurf - ',nCurrVol.surfDet.surfName];
setStatusTxt(sprintf('Switched to %s',nCurrVol.surfDet.surfName));

% save out updated data
setappdata(f_h,'currVol',nCurrVol);
setappdata(f_h,'camCont',camCont);

end