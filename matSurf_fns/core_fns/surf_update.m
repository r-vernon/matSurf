function surf_update(handles,currVol,force)
% surf_update checks if showing data on surface, if yes, updates surface
% force overrides check, and forces update

if nargin < 3, force = false; end

if force || handles.togData.Value == 1
    handles.brainPatch.FaceVertexCData = currVol.currOvrlay.colData;
    drawnow;
end

end