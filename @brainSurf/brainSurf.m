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
    
    % =====================================================================
    
    properties (SetAccess = private) % visible (but not setable) outside class
        
        % -------------------------------------------------------------
        % surface properties
        
        % details about surface (surfName, surfPath, curvPath)
        surfDet
        
        % triangulation (needed to display surface)
        TR 
        
        % -------------------------------------------------------------
        % overlay properties
        
        % current overlay
        currOvrlay  = struct('name','','data',[],'colData',[],'mask',[],...
            'addInfo',struct('cmap','','dLim',[],'cLim',[],'altBase',[]));
        ovrlayNames % cell array of all overlays loaded
        nOvrlays % number of overlays
        
        % -------------------------------------------------------------
        % ROI properties
        
        % set of points ROIs will be plotted on (floating just above surface)
        ROIpts
        
    end
    
    % =====================================================================
    
    properties (Access = private) % only accessible within class
        
        % -------------------------------------------------------------
        % colormap information
        
        colMap % colormap class
        
        % -------------------------------------------------------------
        % surface properties
        
        G % graph
        nVert % number of vertices
        
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
        
    end
    
    % =====================================================================
    
    methods
        
        function obj = brainSurf(colMap)
            % Constructor - initialises the object
            %
            % (opt.) colMap, colormap class for overlays, will create a
            %        new instance if not provided
            % (set.) obj.colMap, see colMap above
            % (set.) obj.nOvrlays, number of data overlays
            
            % save out color map
            if nargin < 1
                obj.colMap = cmaps;
            else
                obj.colMap = colMap;
            end
            
            % save out nOverlays
            obj.nOvrlays = length(obj.dataOvrlay);
            
        end
        
        % =================================================================
        % Surface functions
        
        surface_load(obj,surf2load)
        % function to load in Freesurfer surface
        % sets TR, G, nVert, ROIpts
        
        surface_setDetails(obj,surfPath,curvPath,surfName)
        % function to set surface details
        % sets surfDet
        
        % =================================================================
        % Overlay functions
        
        ovrlay_base(obj,curv2load,sulcusCol,gyrusCol)
        % function to load in base overlay, based upon curvature
        % sets baseOvrlay, currOvrlay
        
        % -----------------------------------------------------------------
        
        [success,ind] = ovrlay_add(obj,newOvrlay,varargin)
        % function to add an additional overlay to the surface
        % sets dataOvrlay, ovrlayNames, currOvrlay, nOvrlays
        
        % -----------------------------------------------------------------
        
        [success, ind] = ovrlay_remove(obj,ovrlay)
        % function to remove overlay
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
        
    end % private, hidden methods
    
end