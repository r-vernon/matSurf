classdef mS_volStore < handle
    % class to store handles to surfaces, so can swap them out if needed
    %
    % all functions will set all properties
    
    properties (SetAccess = private)
        
        vol = brainSurf([]) % will store all volumes
        nVol = 0;           % will store number of volumes
        cVol = 0;           % will store current volume

    end
    
    properties (Dependent)
        
        vNames % cell array w/ names of all volumes
        curVol % will return current volume
        
    end
    
    methods
        
        function obj = volStore(brainSurf)
            % Constructor - initialises the object
            %
            % (opt.) brainSurf, instance of a brainSurf class to save in
            %        vol
            
            % if pass a brainSurf object, iniate with one
            if nargin == 1
                obj.vol(1) = brainSurf;
                obj.nVol = 1;
                obj.cVol = 1;
            end
            
        end
        
        function [brainSurf] = addVol(obj,brainSurf)
            % function to add a volume
            %
            % (req.) brainSurf, new instance of brainSurf class to store
            % (ret.) brainSurf, passes back a copy of brainSurf so can add
            %        a new vol, and save it locally at same time
            
            obj.nVol = obj.nVol + 1;       % inc. num volumes
            obj.vol(obj.nVol) = brainSurf; % save brainSurf class in vol
            obj.cVol = obj.nVol;           % update current volume
            
        end
        
        function [success] = delVol(obj,ind)
            % function to delete a volume
            %
            % (req.) ind, index of brainSurf class to delete
            % (ret.) success, true if successfully deleted
            
            success = false;
            
            % make sure it's a valid ind (unpacking cell first if req.)
            if iscell(ind), ind = ind{:}; end
            if isempty(ind) || ~iscalar(ind) || ~isinteger(ind) || ...
                    ind < 1 || ind > obj.nVol
                warning('Index not valid, not deleting volume');
                return
            end
            
            obj.vol(ind) = [];              % delete brainSurf class in vol
            obj.vNames(ind) = [];           % delete corresponding name
            obj.nVol = obj.nVol - 1;        % dec. num volumes
            obj.cVol = min([obj.nVol,ind]); % update current volume
            success = true;
            
        end
        
        function vN = get.vNames(obj)
            % function to calculate and return volume names when requested
            
            if obj.nVol == 0
                vN = '';
            else
                vN = {obj.vol(:).surfDet.surfName};
            end
            
        end
        
        function cV = get.curVol(obj)
            % function to return current volume
            
            if obj.nVol == 0
                cV = '';
            else
                cV = obj.vol(obj.cVol);
            end
            
        end
        
    end
    
end