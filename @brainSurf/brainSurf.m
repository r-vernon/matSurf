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
    
    properties (SetAccess = private) % visible (but not setable) outside class
        
        % -------------------------------------------------------------
        % surface properties

        surfDet % details about surface (surfName, surfPath, curvPath)
        TR      % triangulation (needed to display surface)
        
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
        ROIs = struct('name','','selVert',[],'allVert',[]);
        
        ROIcol = [0,0,0] % ROI color
        nROIs  = 0       % number of ROIs

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

        % lineInd - NaN delimited array, with vertices for all ROIs
        % markInd - notes manually clicked points to mark with marker
        ROI_lineInd = zeros(1e4,1,'single') % single to allow NaNs
        ROI_markInd = zeros(100,1,'single')
        
        % Shortest path data for all vertices to clicked vertex
        ROI_shortestPaths
        
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

        end
        
        % =================================================================
        % Surface functions
        
        surface_load(obj,surf2load)
        % function to load in Freesurfer surface
        % gets surfDet
        % sets TR, nVert, ROIpts, G
        
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
        
        
    end
    
    % =====================================================================
    
    methods (Access = private, Hidden = true)
        % internal methods for the class only
        
        ovrlayInd = ovrlay_find(obj,ovrlay)
        % function to return overlay index corresponding to overlay
        % gets nOvrlays, dataOvrlay, baseOvrlay
        
    end % private, hidden methods
    
end