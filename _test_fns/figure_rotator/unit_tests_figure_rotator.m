%% Unit Tests for Figure Rotator
%
% These are a series of tests for the FigureRotator. They also serve as example
% of various ways to use the tool.
%
% Copyright 2014 Tucker McClure

%%
% Here's a simple example.

% Make a plot.
figure();
plot3(randn(1, 10), randn(1, 10), randn(1, 10));
drawnow();

% Put a FigureRotator on it.
f = FigureRotator();

%%
% The FigureRotator can later be stopped by calling the Stop() function.

f.Stop();

%%
% It's often helpful to specify the initial camera parameters, like
% position, target, up vector, and view angle. These can all be passed to
% the constructor.

f = FigureRotator(gca, 'CameraTarget',    [0 0 0], ...
                       'CameraPosition',  [15 0 0], ...
                       'CameraUpVector',  [0 0 1], ...
                       'CameraViewAngle', 60);

%%
% The FigureRotator allows complete 3D rotation, so if you start losing
% track of "up", you can always re-align the camera's up vector with the 
% axes' [0 0 1] by calling RestoreUp(). You can also double-click to do this.

f.RestoreUp();

%%
% This object uses the figure's WindowButtonUpFcn, WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowScrollWheelFcn callbacks. If those are
% necessary for other tasks as well, callbacks can be attached to the
% FigureRotator, which will pass all arguments on to the provided callback
% function.
%
% Example:

f = FigureRotator(gca);
f.AttachCallback('WindowButtonDownFcn', 'disp(''clicked'');');

%%
% Or multiple callbacks can be set with a single call:

f.AttachCallback('WindowButtonDownFcn',   'disp(''down'');', ...
                 'WindowButtonUpFcn',     'disp(''up'');', ...
                 'WindowButtonMotionFcn', 'disp(''moving'');', ...
                 'WindowScrollWheelFcn',  @(~, ~) disp('scrolling'), ...
                 'KeyPressFcn',           @(~, ~) disp('key'));

%%
% When we stop the FigureRotator, the callbacks are "given" to the figure, so
% they will still happen.

f.Stop();

%%
% Enough of that.
close all;

%%
% A single FigureRotator can control multiple axes, even axes across
% multiple figures.
%
% Example:

figure(1);
clf();
ha1 = subplot(2, 1, 1);
peaks;
ha2 = subplot(2, 1, 2);
peaks;

figure(2);
clf();
peaks;
ha3 = gca();

f = FigureRotator([ha1 ha2 ha3]);

%%
% We can still provide callbacks.

f.AttachCallback('WindowButtonDownFcn',   'disp(''down'');', ...
                 'WindowButtonUpFcn',     'disp(''up'');', ...
                 'WindowScrollWheelFcn',  @(~, ~) disp('scrolling'), ...
                 'KeyPressFcn',           @(~, ~) disp('key'));

%% Test off-centered rotation with odd data ratios.

close all;
[x, y, z] = sphere(64);
surf(1e3*x + 1000, 1e3*y, 1e-3*z);
drawnow();
FigureRotator();
