function [col,alpha,wroteImg] = cam_screenshot(f_h,varargin)
% function to save a screenshot of the current view
%
% (req.) f_h, figure handle to matSurf figure containing view
% (req.) varargin, name/value pairs or structure containing:
%
%     name         default  description
%   - res          150,     image resolution in pixels/inch (range 72:600)
%   - fmt          jpg,     image format (jpg, png or tif)
%   - qual         85,      if jpg, jpg quality (range 0:100)
%   - bgStyle      s,       (s)olid or (t)ransparent background
%                           (if transparent, fmt forced to be png)
%   - bgCol,       [1,1,1], bg colour, if solid bg (rgb triplet range 0:1)
%   - showROIs,    true,    show ROIs or not
%   - cropBorders, false,   crop empty borders or not
%   - filename,    '',      filename, if blank/invalid won't write image
%
% (ret.) col, image matrix generated from screenshot
% (ret.) alpha, either transparency map, or index for borders
% (ret.) wroteImg, true if image was written to disk

wroteImg = false;

% get data
handles = getappdata(f_h,'handles');

%--------------------------------------------------------------------------
% parse additional arguments in

% create some tests for the input arguments
csTst  = @(x) numel(x) == 3 && isrealnum(x(1),1) && isrealnum(x(2),1) && isrealnum(x(3),1);
fmtTst = @(s) ischar(s) && any(strcmpi(s,{'jpg','png','tif'}));
bgTst  = @(s) ischar(s) && ~isempty(s) && any(strcmpi(s(1),{'s','t'}));
lgcTst = @(l) isscalar(l) && (islogical(l) || isrealnum(l,0,1));
fnmTst = @(s) ischar(s) && exist(fileparts(s),'dir');

% parse away
p = inputParser;
addOptional(p,'currSize',[],csTst);                % current size of axis panel and ppi
addParameter(p,'res',150,@(x) isrealnum(x));       % image resolution
addParameter(p,'fmt','jpg',fmtTst);                % image format (jpg, png or tif)
addParameter(p,'qual',85,@(x) isrealnum(x,0,100)); % if jpg, jpg quality
addParameter(p,'bgStyle','s',bgTst);               % (s)olid or (t)ransparent background
addParameter(p,'bgCol',[1,1,1],@(x) iscol(x));     % background colour (if solid bg)
addParameter(p,'showROIs',true,lgcTst);            % show ROIs or not
addParameter(p,'cropBorders',false,lgcTst);        % crop empty borders or not
addParameter(p,'filename','',fnmTst);              % filename, if writing image
parse(p,varargin{:});

% grab the results...
currSize = p.Results.currSize;
targRes = p.Results.res;
fmt = lower(p.Results.fmt);
qual = p.Results.qual;
bgCol = p.Results.bgCol;
showROIs = p.Results.showROIs;
cropBorders = p.Results.cropBorders;
filename = p.Results.filename;

%--------------------------------------------------------------------------
% do a little extra parsing...

% if not set, get inner size of panel (in pixels)
if isempty(currSize)
    oldUnits = handles.axisPanel.Units;
    handles.axisPanel.Units = 'pixels';
    currSize = [1,1,handles.axisPanel.InnerPosition(3:4)];
    handles.axisPanel.Units = oldUnits;
    
    ppi = get(groot,'ScreenPixelsPerInch');
else
    ppi = currSize(3);
    currSize = [1,1,currSize(1:2)];
end

% limit res to between 72 and 600
if     targRes < 72,  targRes = 72;
elseif targRes > 600, targRes = 600;
end

% check if using (s)olid background, or transparent
if strcmpi(p.Results.bgStyle(1),'s')
    useTransparency = 0;
else
    useTransparency = 1;
end

% make sure colour lies in range 0:1
if isa(bgCol,'uint8') || max(bgCol) > 1
    bgCol = double(bgCol-1)/254;
end

% check if should write image, or just return it
if isempty(filename)
    writeImg = false;
else
    writeImg = true;
end

%--------------------------------------------------------------------------

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
if ~showROIs
    delete(newHandles.brainROI);
end
    
% set all handle units to pixels (probably doesn't matter but makes
% everything 'absolute' (ish) - want to minimise ambiguity)
set(allchild(screenshotFig),'Units','pixels');

% make sure everything rendered
drawnow; pause(0.05);

%--------------------------------------------------------------------------

% calculate ratio with target resolution
targRatio = targRes/ppi;

% set targRes as string
targResStr = ['-r' num2str(targRes)];

%--------------------------------------------------------------------------
% get screenshot

% get screenshot with black background
set(screenshotFig,'Color','black','Position',currSize);
blBG = print(screenshotFig,'-opengl',targResStr,'-noui','-RGBImage');
    
if useTransparency

    % cast blBG to double
    blBG = double(blBG);
    
    % get screenshot with white background
    set(screenshotFig,'Color','white','Position',currSize);
    whBG = double(print(screenshotFig,'-opengl',targResStr,'-noui','-RGBImage'));

    % compute alpha and color
    alpha = round(sum(blBG - whBG,3))/(3*255) + 1;
    col = alpha;
    col(col==0) = 1;
    col = uint8(bsxfun(@rdivide,blBG,col));
    
    %{
    Alpha/color calculation notes:
    
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
else
    
    % get screenshot with desired background color
    set(screenshotFig,'Color',bgCol,'Position',currSize);
    col = print(screenshotFig,'-opengl',targResStr,'-noui','-RGBImage');
    
    % spoof alpha with black background screenshot (for cropping purposes)
    alpha = any(blBG,3);
    
end

%--------------------------------------------------------------------------
% (optionally) crop

if cropBorders
    
    % get the current number of rows, cols
    imSz = size(alpha);
    
    % find all (consecutive) zero rows
    nonZeroRows = find(any(alpha,2));
    zeroRows = [1:nonZeroRows(1), nonZeroRows(end):imSz(1)];
    if nonZeroRows(1)   == 1,       zeroRows(1)   = []; end
    if nonZeroRows(end) == imSz(1), zeroRows(end) = []; end
    
    % delete all zero rows
    col(zeroRows,:,:) = [];
    alpha(zeroRows,:) = [];
    
    % find all (consecutive) zero cols
    nonZeroCols = find(any(alpha,1));
    zeroCols = [1:nonZeroCols(1), nonZeroCols(end):imSz(2)];
    if nonZeroCols(1)   == 1,       zeroCols(1)   = []; end
    if nonZeroCols(end) == imSz(2), zeroCols(end) = []; end
    
    % delete all zero cols
    col(:,zeroCols,:) = [];
    alpha(:,zeroCols) = [];
    
end

%--------------------------------------------------------------------------
% (optionally) save out the picture

if writeImg
    
    % For png, compute the resolution in metres (1 inch = 2.54cm = 0.0254m)
    if strcmp(fmt,'png')
        targRes = targRatio * ppi/0.0254;
    end
    
    if useTransparency
        imwrite(col,filename,'png','ResolutionUnit','meter',...
            'XResolution',targRes,'YResolution',targRes,'Alpha',alpha);
    else
        if strcmp(fmt,'jpg')
            imwrite(col,filename,'jpg','Quality',qual);
        elseif strcmp(fmt,'png')
            imwrite(col,filename,'png','ResolutionUnit','meter',...
                'XResolution',targRes,'YResolution',targRes);
        else
            imwrite(col,filename,fmt,'Resolution',targRes);
        end
    end
    
    wroteImg = true;

end

%--------------------------------------------------------------------------

% delete figure
delete(screenshotFig);

end