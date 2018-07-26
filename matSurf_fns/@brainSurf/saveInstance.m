function vol = saveInstance(obj)
% save an intance of the class, stores all properties as structure

% -------------------------------------------------------------------------
% public properties

% stores for current camera view
vol.VA_cur = obj.VA_cur;
vol.q_cur = obj.q_cur;

% store selected vertex
vol.selVert = obj.selVert;

% -------------------------------------------------------------------------
% private access properties

% surface properties
vol.surfDet = obj.surfDet;
vol.TR = obj.TR;
vol.centroid = obj.centroid;
vol.nVert = obj.nVert;

% overlay properties
vol.currOvrlay = obj.currOvrlay;
vol.ovrlayNames = obj.ovrlayNames;
vol.nOvrlays = obj.nOvrlays;

% ROI properties
vol.ROIs = obj.ROIs;
vol.roiNames = obj.roiNames;
vol.nROIs = obj.nROIs;

% camera properties
vol.xyzLim = obj.xyzLim;
vol.cam = obj.cam;
vol.viewStore = obj.viewStore;
vol.nViews = obj.nViews;
vol.viewNames = obj.viewNames;

% -------------------------------------------------------------------------
% private properties

% TODO - check colormap for non-default options and save them out

% graph
vol.G = obj.G;

% overlay properties
vol.baseOvrlay = obj.baseOvrlay;
vol.dataOvrlay = obj.dataOvrlay;

% ROI properties
vol.pROIs = obj.pROIs;
vol.ROI_lineInd = obj.ROI_lineInd(1:nnz(obj.ROI_lineInd));
vol.ROI_sPaths = obj.ROI_sPaths;

% -------------------------------------------------------------------------
% additional properties

% store the time the surface was saved
vol.saveTime = datetime('now','Format','d-MMM-y');

end

