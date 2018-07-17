classdef brainSurf < handle
    % brainSurf class that contains all necessary data for a given surface
    % specifically:
    % - Surface itself (triangulation, graph, curvature info)
    % - Overlays (base i.e. curvature, and additional overlays)
    % - ROIs (ROIs drawn on surface)
    %
    % Note:
    % (req.) var, var is [required] input variable
    % (opt.) var, var is [optional] input variable
    % (ret.) var, function [returns] variable var
    % (set.) obj.var, function [sets] variable var to class obj
    %
    % Overlay properties:
    %   vars,    currOvrlay, baseOvrlay, dataOvrlay
    %   name,    name of data overlay
    %   data,    data in overlay, one value for each surface vertex
    %   colData, colour values for the overlay
    %   mask,    transparency mask for overlay
    %   addInfo, any additional info, see ovrlay_add for details
    %
    % ROIs properties:
    %   name,    name of ROI
    %   data,    data in overlay, one value for each surface vertex
    %   colData, colour values for the overlay
    
    % =====================================================================

    properties
        
        % structure with camera properties:
        % NA - name array for corresponding value arrays
        % VA_def/q_def - value array and quaternion for default view
        % VA_cur/q_cur - value array and quaternion for current view
        cam = struct('NA',{},'VA_def',{},'VA_cur',{},'q_def',[],'q_cur',[]);
        
    end
    
    properties (SetAccess = private) % visible (but not *set*able) outside class
        
        % -------------------------------------------------------------
        % surface properties

        surfDet  % details about surface (surfName, surfPath, curvPath)
        TR       % triangulation (needed to display surface)
        centroid % surface centroid
        
        % -------------------------------------------------------------
        % overlay properties
        
        % current overlay
        currOvrlay  = struct('name','','data',[],'colData',[],'mask',[],...
            'addInfo',struct('cmap','','dLim',[],'cLim',[],'altBase',[]));
        
        ovrlayNames  % cell array of all overlays loaded
        nOvrlays = 0 % number of overlays
        
        % -------------------------------------------------------------
        % ROI properties
        
        % main overlay structure
        ROIs = struct('name','','allVert',[],'selVert',[],'visible',true);
        
        roiNames   % cell array of all ROIs loaded
        nROIs  = 0 % number of ROIs
        
        % -------------------------------------------------------------
        % camera properties
        
        % max xyz limited needed for plotting
        xyzLim

        % additional structure for saved views
        viewStore = struct('name','','VA_cur',{});
        nViews    = 0 % number of saved views
        viewNames     % cell array of all views saved
        
    end
    
    % =====================================================================
    
    properties (Access = private) % only accessible within class
        
        % -------------------------------------------------------------
        % colormap information
        
        colMap % colormap class
        
        % -------------------------------------------------------------
        % surface properties
        
        G       % graph
        nVert   % number of vertices
        
        % -------------------------------------------------------------
        % overlay properties
        
        % baseOvrlay stores default overlay, i.e. the curvature
        baseOvrlay = struct('name','','data',[],'colData',[],'mask',[],...
            'addInfo',struct('cmap','','dLim',[],'cLim',[],'altBase',[]));
        
        % dataOvrlay will store any additonal overlays     
        dataOvrlay = struct('name','','data',[],'colData',[],'mask',[],...
            'addInfo',struct('cmap','','dLim',[],'cLim',[],'altBase',[]));
        
        % -------------------------------------------------------------
        % ROI properties
        
        % private ROI structure to map onto ROI_lineInd and ROI_markInd
        % stPos/endPos will contain start/end position for each ROI
        pROIs = struct('name','','stPos',[],'endPos',[]);
        
        % set of points ROIs will be plotted on (floating just above surface)
        % calculated by moving set distance from vertex along vertex normal
        ROIpts

        % lineInd - array with vertices for all ROIs, delimited by index 
        %           to 'NaN' in ROIpts
        % markInd - stores manually clicked points to mark with marker
        ROI_lineInd = zeros(1e5,1,'single') % single to allow NaNs
        ROI_markInd = zeros(1e3,1,'single')
        
        % Shortest path data for all vertices to clicked vertex
        ROI_sPaths
        
    end
    
    % =====================================================================
    
    methods
        
        function obj = brainSurf(colMap)
            % Constructor - initialises the object
            %
            % (opt.) colMap, colormap class for overlays, will create a
            %        new instance if not provided
            % (set.) obj.colMap, see colMap above
            
            % save out color map
            if nargin < 1
                obj.colMap = cmaps;
            else
                obj.colMap = colMap;
            end
            
            % initialise cam
            obj.cam(1).NA = {'CameraPosition','CameraTarget','CameraViewAngle','CameraUpVector'};
            obj.cam(1).VA_def = {[],zeros(1,3,'single'),single(10),single([0,0,1])};
            obj.cam(1).VA_cur = {[],zeros(1,3,'single'),single(10),single([0,0,1])};
            obj.cam(1).q_def  = [1,0,0,0];
            obj.cam(1).q_cur  = [1,0,0,0];
            
        end
        
        % =================================================================
        % Surface functions
        
        surface_load(obj,surf2load)
        % function to load in Freesurfer surface
        % gets surfDet
        % sets TR, nVert, xyzLim, cam, ROIpts, G
        
        surface_setDetails(obj,surfPath,curvPath,surfName)
        % function to set surface details
        % sets surfDet
        
        % =================================================================
        % Overlay functions
        
        ovrlay_base(obj,curv2load,sulcusCol,gyrusCol)
        % function to load in base overlay, based upon curvature
        % gets colMap, surfDet, nVert
        % sets baseOvrlay, currOvrlay
        
        % -----------------------------------------------------------------
        
        [success,ind] = ovrlay_add(obj,newOvrlay,varargin)
        % function to add an additional overlay to the surface
        % gets nVert, nOvrlays, colMap, baseOvrlay
        % sets dataOvrlay, ovrlayNames, currOvrlay, nOvrlays
        
        % -----------------------------------------------------------------
        
        [success, ind] = ovrlay_remove(obj,ovrlay)
        % function to remove overlay
        % gets obj.nOvrlays
        % sets dataOvrlay, ovrlayNames, currOvrlay, nOvrlays
        
        % -----------------------------------------------------------------
        
        [success] = ovrlay_set(obj,ovrlay)
        % function to set current overlay
        % sets currOvrlay
        
        % -----------------------------------------------------------------
        
        [ovrlayData] = ovrlay_get(obj,ovrlay)
        % function to get an overlay
        
        % =================================================================
        % ROI functions
        
        [vCoords,markInd,ind,newROI] = ROI_add(obj,ptClicked,finalPt)
        % function to ROI points
        % gets nROIs, ROIs, ROI_lineInd, ROI_markInd, pROIs, roiNames,
        % ROI_sPaths
        % sets ROIs, pROIs, roiNames, nROIs, ROI_lineInd, ROI_markInd,
        % ROI_sPaths
        
        % =================================================================
        % camera functions
        
        cam_setCurr(obj,varargin)
        % function to set current camera view
        % sets cam
        
        cam_reset(obj)
        % resets camera to default state
        % sets cam
        
    end
    
    % =====================================================================
    
    methods (Access = private, Hidden = true)
        % internal methods for the class only
        
        ovrlayInd = ovrlay_find(obj,ovrlay)
        % function to return overlay index corresponding to overlay
        % gets nOvrlays, dataOvrlay, baseOvrlay
        
        calcCentroid(obj,vert)
        % function to calculate the centroid of a volume
        % sets centroid

    end % private, hidden methods
        
end