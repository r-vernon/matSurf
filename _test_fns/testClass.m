classdef testClass < handle
    
    % =====================================================================
    
    properties % accessible outside class
        
        myVar
        
    end
    
    % =====================================================================
    
    methods
        
        % Constructor - initialise the object
        
        function obj = testClass(varargin)
            
            obj.myVar  = 5;
            
        end
        
    end
    
end