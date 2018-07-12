classdef camControl < handle
    % class that allows interaction with matSurf
    % i.e. mouse clicks, keyboard input
    %
    % partially based upon 'FigureRotator.m'
    % https://uk.mathworks.com/matlabcentral/fileexchange/39558-figure-rotator
    
    properties (Access = private)
        
        % figure handle, size
        f_h
        f_s
        
        % axis handle
        a_h
        
        % structure to hold original camera state of object
        % stores: camera position (camPos), camera target (camTar)
        %         camera view angle (camVA), camera up vector (camUV)
        oState = struct('camPos',[],'camTar',[],'camVA',[],'camUV',[]);
        
        % function that will be called if mouse click, not mouse movement
        clickFn = ''
        
        % state of callback when clicked
        clickSt
        
        % flag to check if mouse moved or not during click
        mMoved = false
        
        % store mouse state when clicked, e.g. 'normal', 'alt', 'extend'
        mState
        
        % store mouse pos
        mPos
        
    end
    
    properties (Dependent)
        
        % custom view will return current camera view as a structure so can
        % save out
        customView
        
    end
    
    methods
        
        function obj = camControl(ax_handle)
            % class constructor
            
            % set axis handle and get figure handle
            obj.a_h = ax_handle;
            obj.f_h = getFigHandle(ax_handle);
            
            % get figure handle in pixels
            obj.f_s = feval(@(x) x(3:4), getpixelposition(obj.f_h));
            
            % store original state
            obj.oState.camPos = ax_handle.CamraPosition;
            obj.oState.camTar = ax_handle.CameraTarget;
            obj.oState.camVA =  ax_handle.CameraViewAngle;
            obj.oState.camUV =  ax_handle.CameraUpVector;
            
        end
        
        function cV = get.customView(obj)
            % function to return current camera position for saved axis
            % same format as oState, except additional field for name
            
            cV = struct(...
                'name','',...
                'camPos',obj.a_h.CamraPosition,...
                'camTar',obj.a_h.CameraTarget,...
                'camVA', obj.a_h.CameraViewAngle,...
                'camUV', obj.a_h.CameraUpVector...
                );
            
        end
        
        function bDownFcn(obj,src,event,varargin)
            % function called when patch button down callback triggered
            
            % save out the callback
            obj.clickFn = src.ButtonDownFcn;
            obj.clickSt = [src,event,varargin(:)'];
            
            % update figure size in case it's changed
            obj.f_s = feval(@(x) x(3:4), getpixelposition(obj.f_h));
            
            % get state of mouse at last click
            obj.mState = obj.f_h.SelectionType;
            
            % get mouse position in pixels
            obj.mPos = getCurrPos;
            
            % set movement and button up functions
            obj.f_h.WindowButtonMotionFcn = @(src,~) obj.mMoveFcn(obj,src);
            obj.f_h.WindowButtonUpFcn     = @(~,~)   obj.bUpFcn(obj);
            
        end
        
    end % normal methods
    
    methods (Hidden = true)
        
        function mMoveFcn(obj,src)
            % function to call for mouse movement
            
            % set mouse moved flag
            obj.mMoved = true;
            
            % calculate distance moved, then update mPos
            newPos = getCurrPos;
            dX = newPos(1) - obj.mPos(1); % delta x (width)
            dY = newPos(2) - obj.mPos(2); % delta y (height)
            obj.mPos = newPos;
            
        end
        
        function bUpFcn(obj)
            % function called when mouse button released on figure
            
            % if no mouse movement, just a click, then aim was to run
            % callback, if mouse movement, then aim was to move surface so
            % already taken care of with mMoveFcn
            
            if ~obj.mMoved
                
                % execute the original callback
                obj.clickFn(obj.clickSt{:});
                
            else
                
                % reset status and callbacks
                obj.mMoved = false;
                obj.f_h.WindowButtonMotionFcn = '';
                obj.f_h.WindowButtonUpFcn     = '';
                
            end
        end
        
    end % hidden methods
    
    methods (Access = private, Hidden = true)
        
        function [currPos] =  getCurrPos(obj)
            % function to get CurrentPos (last clicked mouse position) in
            % pixels
            
            % get current units and last clicked position
            currUnits =  obj.f_h.Units;
            currPos =    obj.f_h.CurrentPoint;
            
            if strcmp(currUnits,'normalised')
                currPos = currPos./obj.f_s;
            elseif ~strcmp(currUnits,'pixels')
                obj.f_h.Units = 'pixels';        % set to pixels
                currPos = obj.f_h.CurrentPoint;  % get point
                obj.f_h.Units = currUnits;       % reset to orig. units
            end
        end
        
    end % private methods
end