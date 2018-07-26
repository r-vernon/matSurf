function loadInstance(obj,vol)
% load an intance of the class, retrieves all properties from structure
%
% (req.) vol, structure of all properties

if ~isstruct(vol)
    error('Can only load structure generated from saveInstance method');
end

% -------------------------------------------------------------------------
% public properties

% current camera view
obj.VA_cur = vol.VA_cur;
obj.q_cur = vol.q_cur;

% selected vertex
obj.selVert = vol.selVert;

% -------------------------------------------------------------------------
% private access properties

% surface properties
obj.surfDet = vol.surfDet;
obj.TR = vol.TR;
obj.centroid = vol.centroid;
obj.nVert = vol.nVert;

% overlay properties
obj.currOvrlay = vol.currOvrlay;
obj.ovrlayNames = vol.ovrlayNames;
obj.nOvrlays = vol.nOvrlays;

% ROI properties
obj.ROIs = vol.ROIs;
obj.roiNames = vol.roiNames;
obj.nROIs = vol.nROIs;

% camera properties
obj.xyzLim = vol.xyzLim;
obj.cam = vol.cam;
obj.viewStore = vol.viewStore;
obj.nViews = vol.nViews;
obj.viewNames = vol.viewNames;

% -------------------------------------------------------------------------
% private properties

% TODO - check colormap for non-default options and save them out

% graph
obj.G = vol.G;

% overlay properties
obj.baseOvrlay = vol.baseOvrlay;
obj.dataOvrlay = vol.dataOvrlay;

% ROI properties
obj.pROIs = vol.pROIs;
obj.ROI_lineInd = expandArray(vol.ROI_lineInd, 1e5/2);
obj.ROI_sPaths = vol.ROI_sPaths;

end

