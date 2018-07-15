classdef camControl < handle
    % class that allows interaction with matSurf
    % i.e. mouse clicks, keyboard input
    %
    % partially based upon 'FigureRotator.m'
    % https://uk.mathworks.com/matlabcentral/fileexchange/39558-figure-rotator
    
%     https://gamedev.stackexchange.com/questions/20758/how-can-i-orbit-a-camera-about-its-target-point
% http://courses.cms.caltech.edu/cs171/assignments/hw3/hw3-notes/notes-hw3.html

    properties
        
        % store function that will be called if no mouse movement
        clickFn = ''
        
    end
    
    properties (Access = private)
        
        % figure handle, size,  axis handle, light handle
        f_h
        f_s
        a_h
        l_h
        
        % structure to hold original camera state of object
        % stores: camera position (camPos), camera target (camTar)
        %         camera view angle (camVA), camera up vector (camUV)
        oState = struct('camPos',[],'camTar',[],'camVA',[],'camUV',[]);
        
        % at click, store state of callback when clicked
        clickSt
        
        % for mouse store:
        % - flag to check if moved or not during click
        % - state when clicked, e.g. 'normal', 'alt', 'extend'
        % - position
        mMoved = false
        mState
        mPos
        
        % principal axis (none, x, y, z (def.))
        princAx = 'z';
        pAxVal = single([0,0,1]);
        
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
            obj.oState.camPos = ax_handle.CameraPosition;
            obj.oState.camTar = ax_handle.CameraTarget;
            obj.oState.camVA =  ax_handle.CameraViewAngle;
            obj.oState.camUV =  ax_handle.CameraUpVector;
            
        end
        
        function updatePrincAx(obj,newPA)
            % updates principal axis
            
            if nargin < 2, newPA = 'z';
            else, newPA = lower(newPA(1));
            end
            
            if any(strcmp(newPA,{'n','x','y','z'}))
                obj.princAx = newPA;
                obj.pAxVal(:) = 0;
                switch newPA
                    case 'n'   % do nothing
                    case 'x',  obj.pAxVal(1) = 1;
                    case 'y',  obj.pAxVal(2) = 1;
                    otherwise, obj.pAxVal(3) = 1; % default to 'z'
                end
            end
            
        end
        
        function setDefState(obj,mode)
            % sets/updates default state of camera position and
            % (optionally) mode
            
            % update figure handle in pixels
            obj.f_s = feval(@(x) x(3:4), getpixelposition(obj.f_h));
            
            % store current state as original state
            obj.oState.camPos = obj.a_h.CameraPosition;
            obj.oState.camTar = obj.a_h.CameraTarget;
            obj.oState.camVA =  obj.a_h.CameraViewAngle;
            obj.oState.camUV =  obj.a_h.CameraUpVector;
            
            % update mode if passed
            if nargin == 2
                obj.updatePrincAx(mode);
            end
            
        end
        
        function cV = get.customView(obj)
            % function to return current camera position for saved axis
            % same format as oState, except additional field for name
            
            cV = struct(...
                'name','',...
                'camPos',obj.a_h.CameraPosition,...
                'camTar',obj.a_h.CameraTarget,...
                'camVA', obj.a_h.CameraViewAngle,...
                'camUV', obj.a_h.CameraUpVector...
                );
            
        end
        
        function bDownFcn(obj,src,event,varargin)
            % function called when patch button down callback triggered
            
            % save out the callback
            obj.clickSt = {src,event,varargin(:)'};
            
            % update figure size in case it's changed
            obj.f_s = feval(@(x) x(3:4), getpixelposition(obj.f_h));
            
            % get state of mouse at last click
            obj.mState = obj.f_h.SelectionType;
            
            % get mouse position in pixels
            obj.mPos = obj.getCurrPos;
            
            % set button up function
            obj.f_h.WindowButtonUpFcn     = @(~,~) obj.bUpFcn();
            
            % set movement function if relevant button press
            % (normal - LClick, alt - RClick, extend - ScrollClick/LRClick)
            % will use normal for rotate, extend for pan
            if strcmp(obj.mState,'normal') || strcmp(obj.mState,'extend')
                obj.f_h.WindowButtonMotionFcn = @(~,~) obj.mMoveFcn();
            end
            
        end
        
    end % normal methods
    
    methods (Hidden = true)
        
        function mMoveFcn(obj)
            % function to call for mouse movement
            
            % set mouse moved flag
            obj.mMoved = true;
            
            % calculate distance moved, then update mPos
            newPos = obj.getCurrPos;
            dXY = newPos - obj.mPos;... % delta xy - width/height
            obj.mPos = newPos;
            
            % flip dXY as mouse left should move camera right
            dXY = -dXY;
            
            if strcmp(obj.mState,'extend') % if in pan state
                dXY = dXY * obj.a_h.CameraViewAngle/500;
            end
            
            tmpAxVal = obj.pAxVal;
            if ~strcmp(obj.princAx,'n')
                
                % check if we're upside down
                currCamUV = obj.a_h.CameraUpVector;
                upsidedown = (currCamUV(tmpAxVal==1) < 0);
                if upsidedown
                    dXY(1) = -dXY(1);
                    tmpAxVal = -tmpAxVal;
                end
                
                % if camera up vector not parallel with view direction, set up
                % vector
                if any(obj.crossSimple(tmpAxVal,obj.a_h.CameraPosition-obj.a_h.CameraTarget))
                    obj.a_h.CameraUpVector = tmpAxVal;
                end
                
                switch obj.mState
                    case 'normal' % normal left click - rotate
                        camorbit(obj.a_h,dXY(1),dXY(2),'data',obj.princAx);
                    case 'extend'
                        campan(obj.a_h,dXY(1),dXY(2),'data',obj.princAx);
                end          
            else
                switch obj.mState
                    case 'normal' % normal left click - rotate
                        camorbit(obj.a_h,dXY(1),dXY(2),ob.princAx);
                    case 'extend'
                        campan(obj.a_h,dXY(1),dXY(2),obj.princAx);
                end
            end
            
            % TODO  update light source
            drawnow;
            
        end
        
        %function wMoveFcn(obj,src,event)
        
        
        function bUpFcn(obj)
            % function called when mouse button released on figure
            
            % if no mouse movement, just a click, then aim was to run
            % callback, if mouse movement, then aim was to move surface so
            % already taken care of with mMoveFcn
            
            if strcmp(obj.mState,'alt')
                % right click detected, for now do nothing...
                return;
            end
            
            if ~obj.mMoved && ~isempty(obj.clickFn)
                % execute the original callback
                obj.clickFn(obj.clickSt{:});
            end
            
            % reset status and callbacks
            obj.mMoved = false;
            obj.f_h.WindowButtonMotionFcn = '';
            obj.f_h.WindowButtonUpFcn     = '';
            
        end
        
    end % hidden methods
    
    methods (Access = private, Hidden = true)
        
        function [currPos] = getCurrPos(obj)
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
    
    methods (Static)
        function c=crossSimple(a,b)
            c(1) = b(3)*a(2) - b(2)*a(3);
            c(2) = b(1)*a(3) - b(3)*a(1);
            c(3) = b(2)*a(1) - b(1)*a(2);
        end
    end
end