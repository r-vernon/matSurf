
delROI = false;
targRes = 300;
useTransparency = 1; % transparent background
cropEdges = 0;

% get inner size of panel (in pixels)
oldUnits = handles.axisPanel.Units;
handles.axisPanel.Units = 'pixels';
currSize = [1,1,handles.axisPanel.InnerPosition(3:4)];
handles.axisPanel.Units = oldUnits;

% delete any existing screenshotFigs just in case
delete(findobj('Type','Figure','Tag','screenshotFig'));

% by default print will include uipanels, so make new temp figure to print
% from, keeping as much the same as possible
% (InvertHardCopy (change fig/axis color to white when printing) off)
screenshotFig = figure('Name','scrSh','Tag','screenshotFig',...
    'NumberTitle','off','FileName','scrSh.fig','Units','pixels',...
    'Position',currSize,'Visible','off','InvertHardCopy','off',...
    'MenuBar','none','DockControls','off');

% copy over axis
copyobj(handles.brainAx,screenshotFig);

% get new figure handles
newHandles = guihandles(screenshotFig);

% delete the marker and optionally ROIs
delete(newHandles.markPatch);
if delROI
    newHandles.brainROI.Visible = 'off';
end
    
% set all handle units to pixels (probably doesn't matter but makes
% everything 'absolute' (ish) - want to minimise ambiguity)
set(allchild(screenshotFig),'Units','pixels');

% make sure everything rendered
drawnow; pause(0.05);

%--------------------------------------------------------------------------

% get the number of pixels per inch
ppi = get(groot,'ScreenPixelsPerInch');

% calculate ratio with target resolution
targRatio = targRes/ppi;

% set targRes as string
targResStr = ['-r' num2str(targRes)];

% get screenshot with white background
set(screenshotFig,'Color','white','Position',currSize);
whBG = double(print(screenshotFig,'-opengl',targResStr,'-noui','-RGBImage'));

% get screenshot with black background
set(screenshotFig,'Color','black','Position',currSize);
blBG = double(print(screenshotFig,'-opengl',targResStr,'-noui','-RGBImage'));

% compute alpha, and shortly color (doing this regardless of transparency,
% as may want to crop transparent areas)
%{
    presumably using glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    i.e. foreground mult. by alpha, background mult. by 1-alpha
    let a=alpha, ac=actual colour, bc=background colour, pc=perceived colour
    a.ac + (1-a)bc1 = pc1, a.ac + (1-a)bc2 = pc2
    some rearranging gets you a = (pc2 - pc1 -bc2 + bc1)/(bc1-bc2)
    let bc1 = white (255), bc2 = black (0)
    a = (pc2-pc1+255)/255 = (pc2-pc1)/255 + 1
    (need to multiply by 3 as will be computing over 3 channels)
    (using round as should be integer only calculation at that point)
    
    some further rearranging gets you ac = (c2-bc2(1-a))/a = c2/a
    however, when alpha = 0, colour undefined as transparent, set a(a=0)=1
    then just compute color!
%}
alpha = round(sum(blBG - whBG,3))/(3*255) + 1;

if useTransparency
    col = alpha;
    col(col==0) = 1;
    col = uint8(bsxfun(@rdivide,blBG,col));
else
    col = uint8(whBG);
end

% crop if doing that
if cropEdges
    
    % delete all zero rows
    zeroRows = find(~any(alpha,2));
    col(zeroRows,:,:) = [];
    alpha(zeroRows,:) = [];
    
    % delete all zero cols
    zeroCols = find(~any(alpha,1));
    col(:,zeroCols,:) = [];
    alpha(:,zeroCols) = [];
end

% Compute the resolution in metres
% (1 inch = 2.54cm = 0.0254m)
res = targRatio * ppi/0.0254;
imwrite(col, './test.png', 'Alpha', alpha, 'ResolutionUnit', 'meter',...
    'XResolution', targRes, 'YResolution', targRes);

%--------------------------------------------------------------------------

% % delete figure
delete(screenshotFig);

