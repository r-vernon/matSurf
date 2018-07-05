classdef cmaps < handle
    % cmaps class that contains all required colormap info for overlays
    %
    % Note:
    % (req.) var, var is [required] input variable
    % (opt.) var, var is [optional] input variable
    % (ret.) var, function [returns] variable var
    % (set.) obj.var, function [sets] variable var to class obj
    %
    % Colormap properties:
    %   var,  colMaps
    %   name, name of colormap
    %   desc, description of colormap
    %   cmap, colormap data
    
    % =====================================================================
    
    properties (Constant) % unchangeable properties for class
        
        n = 256;                % number of colours in cmaps
        def_colMap = 'parula';  % default color map to use, always have ind = 1
        
    end
    
    % =====================================================================
    
    properties (Access = private) % only accessible within class
        
        % colMaps will store all the colormaps to be used
        colMaps = struct('name','','desc','','cmap',[])
        nCmaps % number of colormaps
        
        x % for linear interpolation
        colBar % for displaying colorbars
        
    end
    
    % =====================================================================
    
    methods
        
        function obj = cmaps
            % Constructor - initialises the object
            %
            % (set.) obj.x, linear range 0:1, size obj.n
            % (set.) obj.colBar, a 2D array sized [obj.n, obj.n/8], ranging
            %        0:1, used as a color bar
            % (set.) obj.colMaps, structure of all initially available
            %        color maps (contains name, description (desc) and 
            %        colormap (cmap) sized [obj.n, 3])
            % (set.) obj.nCmaps, number of colormaps available
            
            % -------------------------------------------------------------
            
            % set linear range and create colorbar from it
            obj.x = linspace(0,1,obj.n);
            obj.colBar = repmat(obj.x,round(obj.n/8),1);
            
            % -------------------------------------------------------------
            % create the colormaps that can be used
            % colormap 1 should always be default!
            
            obj.colMaps(1) = struct(...
                'name',obj.def_colMap,...
                'desc','[default] approximately linear blue-green-yellow',...
                'cmap',parula(obj.n));
            obj.colMaps(2) = struct(...
                'name','heat',...
                'desc','shades of red/yellow, increasing in lightness',...
                'cmap',hot(obj.n));
            obj.colMaps(3) = struct(...
                'name','cool',...
                'desc','shades of blue, increasing in lightness',...
                'cmap',obj.colMaps(2).cmap(:,[3,2,1]));
            
            % -------------------------------------------------------------
            
            % update number of colormaps
            obj.nCmaps = length(obj.colMaps);
            
        end
        
        % -----------------------------------------------------------------
        
        colVals = getColVals(obj,dataVals,cmap,cLim)
        % function to get color vals corresponding to dataVals
        
        % -----------------------------------------------------------------
        
        list_cmaps(obj,disp_cmaps)
        % function that lists available colormaps
        
    end % normal methods
    
    % =====================================================================
    
    methods (Access = private, Hidden = true)
        % internal methods for the class only
        
        colInd = find_cmap(obj,cmap)
        % function to return color index corresponding to colormap
        
    end % private, hidden methods
    
    % =====================================================================
    
    methods (Static) 
        % methods that don't need a copy of the cmaps class
        
        [colData] = checkColRange(colData)
        % function to make sure colours lie in range 0:1
        
    end % static methods
    
    
end % class