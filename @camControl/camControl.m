classdef camControl < handle
    % class that allows interaction with matSurf
    % i.e. mouse clicks, keyboard input
    %
    % partially based upon 'FigureRotator.m'
    % https://uk.mathworks.com/matlabcentral/fileexchange/39558-figure-rotator
    
    properties (Access = private)
        
        f_h % figure handle
        a_h % axis handle
        
        % structure to hold original camera state of object
        % stores: camera position (camPos), camera target (camTar)
        %         camera view angle (camVA), camera up vector (camUV)
        oState = struct('camPos',[],'camTar',[],'camVA',[],'camUV',[]);
        
        % flag to check if mouse moved or not during click
        mouseMoved = false
        
        % function that will be called if mouse click, not mouse movement
        clickFn
        
        % store mouse state when clicked, e.g. 'normal', 'alt', 'extend'
        mState
        
        