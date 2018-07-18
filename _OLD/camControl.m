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
        
        % store xyz axis limits
        xyzLim
        
        % store sensitivity for rotation, panning and zooming
        rSens = 1.5
        pSens = 1.0
        zSens = 1.0
        
    end
    
    properties (Access = private)
        
        % figure handle/size, axis handle, transform handle
        f_h
        f_s
        a_h
        t_h
        
        % store initial camera position  and view angle for resetting camera
        initCamPos
        initCamVA
        
        % for mouse store:
        % - flag to check if moved or not during click
        % - state when clicked, e.g. 'normal', 'alt', 'extend'
        % - previous position for axis and figure
        mMoved = false
        mState
        a_mPos1
        f_mPos1
        
        % store whether clicked patch (1) or axis (0)
        % if did click patch, also store intersection point
        clPatch = false
        ip
        
        % store current rotation as quaternion 1
        qForm1 = [1,0,0,0]
        
        % store time stamp
        tStmp
        
    end
    
    properties (Dependent)
        
        % custom view will return current camera view as a structure so can
        % save out
        customView
        
    end
    
    methods
        
        function obj = camControl(xform_handle)
            % class constructor
            
            % set transform handle, get figure and axis handle
            obj.t_h = xform_handle;
            obj.a_h = xform_handle.Parent;
            obj.f_h = getFigHandle(obj.a_h);
            obj.f_s = obj.f_h.Position(3:4);
            
        end
        
        setDefState(obj)
        % stores current state as default state of camera position
        % sets initCamPos, initCamVA
        
        function resetState(obj,~,~)
            % sets default state as current state of camera position

            set(obj.a_h,...
                'CameraPosition',  obj.initCamPos, 'CameraTarget',   [0,0,0],...
                'CameraViewAngle', obj.initCamVA,  'CameraUpVector', [0,0,1]);
            obj.qForm1 = [1,0,0,0];
            obj.t_h.Matrix = obj.qRotMat(obj.qForm1);
            
            setStatusTxt('camera reset');
            
        end
        
        function cV = get.customView(obj)
            % function to return current camera position for saved axis
            % with additional field for name
            
            cV = struct(...
                'name','',...
                'camPos',obj.a_h.CameraPosition,...
                'camTar',obj.a_h.CameraTarget,...
                'camVA', obj.a_h.CameraViewAngle,...
                'camUV', obj.a_h.CameraUpVector,...
                'xform', obj.qForm1...
                );
            
        end
        
        function bDownFcn(obj,src,event)
            % function called when patch button down callback triggered
            
            % get state of mouse at click
            obj.mState = obj.f_h.SelectionType;
            obj.tStmp = clock;
            
            % set mouse movement function if relevant button press
            % (normal - LClick, alt - RClick, extend - ScrollClick/LRClick)
            % only using normal (rotate) and extend (pan) currently
            
            switch obj.mState(1)
                case 'n'  % normal, rotate (or possible click)
                    
                    % work out where the callback came from
                    if strcmp(src.Tag,'brainAx') % axis click
                        obj.clPatch = false;
                    else
                        % was a patch click, store intersection point
                        obj.clPatch = true;
                        
                        % must *undo* current quat. rotation, use q' = r*q*inv(r)
                        % but actually want inv. rotmat, so doing inv(r)*q*r...
                        obj.ip = obj.qMul([0,event.IntersectionPoint],obj.qForm1);
                        obj.ip = obj.qMul(obj.qInv(obj.qForm1),obj.ip);
                        obj.ip = obj.ip(2:4);
                    end
                    
                    obj.a_mPos1 = obj.getCurrPos;       % get mouse pos on 'sphere'
                    obj.f_h.WindowButtonMotionFcn = @obj.mMoveFcn_rot;
                    
                case 'e'  % extend, pan
                    
                    obj.f_mPos1 = obj.f_h.CurrentPoint; % get mouse pos on figure
                    obj.f_s = obj.f_h.Position(3:4);    % get current figure size
                    obj.f_h.WindowButtonMotionFcn = @obj.mMoveFcn_pan;
                    
                otherwise % alt, do nothing
                    obj.f_h.WindowButtonMotionFcn = '';
            end
            
            % set button up function
            obj.f_h.WindowButtonUpFcn = @obj.bUpFcn;
            
        end
        
    end % normal methods
    
    methods (Hidden = true)
        
        function mMoveFcn_rot(obj,~,~)
            % function to call for mouse movement
            
            % get new position and time
            mPos2 = obj.getCurrPos;
            cTime = clock;
            
            % make sure we've moved reasonable amount...
            % (doing this before scaling so don't magnify false +ves)
            if norm(mPos2-obj.a_mPos1) < 0.01 || etime(cTime,obj.tStmp) < 1/24
                return; 
            end
            obj.mMoved = true;
            obj.tStmp = cTime;
            
            % calculate unit vector (u), and angle of rotation (theta, th)
            u = cross(obj.a_mPos1,mPos2);             % calc vector
            normU = norm(u);                          % calc vector norm
            th = atan2(normU,dot(obj.a_mPos1,mPos2)); % calc theta
            u = u/normU;                              % make unit vector
            
            % scale theta by sensitivity
            th = th*obj.rSens;
            
            % convert to unit quaternion and multiply by previous rotation
            qForm2 = [cos(th/2),sin(th/2)*u];
            qForm2 = obj.qMul(qForm2,obj.qForm1);
            
            % convert to rotation matrix to pass for rendering
            qForm2_R = obj.qRotMat(qForm2);
            
            % set the rotation
            obj.t_h.Matrix = qForm2_R;
            
            % update mouse position, rotation qForm to latest values
            obj.a_mPos1 = mPos2;
            obj.qForm1  = qForm2;
            
        end
        
        function mMoveFcn_pan(obj,~,~)
            % function to call for mouse movement

            % get new position
            mPos2 = obj.f_h.CurrentPoint;
            cTime = clock;
            
            % calculate distance moved (dWH - delta width, height)
            dWH = zeros(1,3);
            dWH([1,3]) = (mPos2 - obj.f_mPos1)./obj.f_s;
            
            % make sure we've moved reasonable amount...
            % (doing this before scaling so don't magnify false +ves)
            if hypot(dWH(1),dWH(3)) < 0.01 || etime(cTime,obj.tStmp) < 1/24
                return
            end
            
            % set moved flag, then update last clicked point
            obj.mMoved = true;
            obj.f_mPos1 = mPos2;
            obj.tStmp = cTime;
            
            % scale by sensitivity, then update camera position and target
            dWH = dWH * 100 * obj.pSens;
            set(obj.a_h,...
                'CameraPosition', obj.a_h.CameraPosition - dWH,...
                'CameraTarget',   obj.a_h.CameraTarget   - dWH);
        end
        
        function bUpFcn(obj,src,~)
            % function called when mouse button released on figure
            
            % if no mouse movement, just a click, then aim was to run
            % callback, if mouse movement, then aim was to move surface so
            % already taken care of with mMoveFcn
            
            % if right click detected, for now do nothing...
            if strcmp(obj.mState,'alt'), return; end
            
            if ~obj.mMoved && obj.clPatch && ~isempty(obj.clickFn)
                % execute the original callback
                obj.clickFn(src,obj.ip);
            end
            
            % reset status and callbacks
            obj.mMoved = false;
            obj.f_h.WindowButtonMotionFcn = '';
            obj.f_h.WindowButtonUpFcn     = '';

        end
        
    end % hidden methods
    
    methods (Access = private, Hidden = true)
        
        [currPos] = getCurrPos(obj)
        % function to get current mouse position
        
    end 
    
    methods (Static)
        
        [q2] = qInv(q1)
        % returns inverse of unit quaternion
 
        [q3] = qMul(q1,q2)
        % multiplies two quaternions
        
        [qR] = qRotMat(q1)
        % get rotation matrix from quaternion
        
    end
end