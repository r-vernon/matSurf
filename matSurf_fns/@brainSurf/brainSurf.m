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
    % Surface properties:
    %   SUBJECTS_DIR, search path for surface
    %   subject,      name of subject
    %   surfName,     name of surface
    %   hemi,         surface hemisphere (lh - left, rh - right)
    %   surfType,     (inf)lated, (wh)ite or (pial)
    %   surfPath,     path to surface file
    %   curvPath,     path to curv file
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
    %   nVert,   number of vertices in ROI boundary
    %   allVert, all vertices in ROI boundary
    %   selVert, manually selected vertices in ROI boundary
    %   visible, if true, show ROI, false, hide it
    
    % =====================================================================

    properties
        
        % stores for current camera view, see cam in properties below
        VA_cur = {}
        q_cur
        
        % store selected vertex
        selVert
        
        % store current ROI
        currROI = 0
        
    end
    
    properties (SetAccess = private) % visible (but not *set*able) outside class
        
        % -------------------------------------------------------------
        % surface properties
        
        % details about surface
        surfDet = struct('SUBJECTS_DIR','','subject','',...
            'surfName','','hemi','','surfType','',...
            'surfPath','','curvPath','');
        
        TR       % triangulation (needed to display surface)
        centroid % surface centroid
        nVert    % number of vertices
        
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
        ROIs = struct('name',{},'nVert',uint32([]),'allVert',{},'selVert',{},'visible',[]);
        nROIs = 0 % number of ROIs
        
        % -------------------------------------------------------------
        % camera properties
        
        % max xyz limited needed for plotting
        xyzLim
        
        % structure with camera properties:
        % NA - name array for corresponding value arrays
        % VA_def/q_def - value array and quaternion for default view
        %
        % VA_cur/q_cur - value array and quaternion for current view
        %                these stored as settable properties above
        cam = struct('NA',{},'VA_def',{},'q_def',[]);
        
        % additional structure for saved views
        viewStore = struct('name',{},'VA_cur',{},'q_cur',[]);
        nViews = 0 % number of saved views
  
    end
    
    % =====================================================================
    
    properties (Access = private) % only accessible within class
        
        % -------------------------------------------------------------
        % colormap information
        
        colMap % colormap class
        
        % -------------------------------------------------------------
        % surface properties
        
        G % graph

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

        % array with vertices for all completed ROIs, delimited by NaNs
        ROI_lineInd;

    end
    
    % =====================================================================
    
    methods
        
        function obj = brainSurf(colMap)
            % Constructor - initialises the object
            %
            % (opt.) colMap, colormap class for overlays, will create a
            %        new instance if not provided
            % (set.) obj.colMap, see colMap above
            % (set.) ROIs, cam, viewStore -> just initialises
            
            % save out color map
            if nargin < 1
                obj.colMap = create_cmaps;
            else
                obj.colMap = colMap;
            end
            
            % initialise ROI
            obj.ROIs(1).name = {};
            
            % initialise cam
            obj.cam(1).NA = {'CameraPosition','CameraTarget','CameraViewAngle','CameraUpVector'};
            obj.cam(1).VA_def = {[],zeros(1,3),10,[0,0,1]};
            obj.cam(1).q_def  = [1,0,0,0];
            obj.VA_cur = {[],zeros(1,3),10,[0,0,1]};
            obj.q_cur  = [1,0,0,0];
            
            % initialise viewStore
            obj.viewStore(1).name = {};
        end
        
        [vol] = saveInstance(obj)
        % save an instance
        
        loadInstance(obj,vol)
        % load a saved instance (sets everything!)
        
        % =================================================================
        % Surface functions
        
        surface_load(obj,surf2load)
        % function to load in Freesurfer surface
        
        surface_setDetails(obj,varargin)
        % function to set surface details
        
        calcCentroid(obj,vert)
        % function to calculate the centroid of a volume

        % =================================================================
        % Overlay functions
        
        ovrlay_base(obj,curv2load,sulcusCol,gyrusCol)
        % function to load in base overlay, based upon curvature
        
        % -----------------------------------------------------------------
        
        [success,ind] = ovrlay_add(obj,newOvrlay,varargin)
        % function to add an additional overlay to the surface

        % -----------------------------------------------------------------
        
        [success, ind] = ovrlay_remove(obj,ovrlay)
        % function to remove overlay
        
        % -----------------------------------------------------------------
        
        [success] = ovrlay_set(obj,ovrlay)
        % function to set current overlay
        
        % -----------------------------------------------------------------
        
        [ovrlayData] = ovrlay_get(obj,ovrlay)
        % function to get an overlay
        
        % -----------------------------------------------------------------

        [ovrlayInd] = ovrlay_find(obj,ovrlay)
        % function to return overlay index corresponding to overlay
        
        % =================================================================
        % ROI functions
        
        [vCoords,newROI] = ROI_add(obj,v2add)
        % function to add ROI points
        
        % -----------------------------------------------------------------
        
        [success,vCoords] = ROI_remove(obj,ROIname)
        % function to remove an ROI
        
        % -----------------------------------------------------------------
        
        ROI_fin(obj)
        % function to finish an ROI

        % -----------------------------------------------------------------
        
        [vCoords,prevVal] = ROI_undo(obj)
        % function to undo last added ROI vertex
        
        % -----------------------------------------------------------------
        
        [vCoords] = ROI_get(obj,vertInd)
        % function that returns all ROI coordinates for plotting
        
        % -----------------------------------------------------------------
        
        [allVert] = ROI_fill(obj,bPts)
        % function to flood fill an ROI
        
        % -----------------------------------------------------------------
        
        [vCoords,ind] = ROI_import(obj,newROIs)
        % function to import ROIs
        
        % -----------------------------------------------------------------
        
        [success] = ROI_updateName(obj,oldName,newName)
        % function to update an ROI name

        % =================================================================
        % camera functions
        
        cam_reset(obj)
        % resets camera to default state
        
    end
    
end