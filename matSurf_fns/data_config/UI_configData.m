
% create test data
ovrlayName = 'my overlay';
data = rand(1e4,2);

% load in threshold button images (should be on path...)
thrPics = load('thrPics.mat');
thrPics = thrPics.thrPics;

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
confDataFig = figure('Name',sprintf('Config. %s data overlay',ovrlayName),...
    'Tag','confDataFig','FileName','confData.fig',...
    'Units','pixels','Position',[100, 100, 1105, 685],'Visible','on',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% grab context menus for copy, and copy/paste
cMenu  = copy_paste_menu(0);
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- OPACITY PANEL ----------------------------------

% panel
opacPan = uipanel(confDataFig,'Tag','opacPan','Title','Opacity',...
    'Units','pixels','Position',[15,550,355,120]);

% mask zeros checkbox
maskZeros = uicontrol(opacPan,'Style','checkbox','Value',1,'String',...
    'Ignore zeros (0s) in dataset (make transparent)',...
    'Tag','maskZeros','Position',[10 65 330 25]);

% transparency text
transText = uicontrol(opacPan,'Style','text','String','Transparency',...
    'HorizontalAlignment','left','FontSize',9,...
    'Tag','transText','Position',[10 35 250 15]);

% transparency slider
transSlide = uicontrol(opacPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.1,0.2],'Value',1,'Tag','transSlide',...
    'Position',[10 13 270 19],'Callback','');

% transparency edit
transEdit = uicontrol(opacPan,'Style','edit','String','1.00',...
    'FontSize',10,'Tag','transEdit','Position',[285 10 60 25],...
    'Callback','','UIContextMenu',cpMenu);

%  ========================================================================
%  ---------------------- COLORMAP PANEL ----------------------------------

% panel
cmapPan = uipanel(confDataFig,'Tag','cmapPan','Title','Colormap',...
    'Units','pixels','Position',[15,265,355,275]);

%---------------------------
% positive/normal colour map

% min/max values
cm_pMinEdit = uicontrol(cmapPan,'Style','edit','String','1234.56',...
    'Tag','cm_pMinEdit','Position',[10 220 80 25],...
    'UIContextMenu',cpMenu);
cm_pMaxEdit = uicontrol(cmapPan,'Style','edit','String','1234.56',...
    'Tag','cm_pMaxEdit','Position',[265 220 80 25],...
    'UIContextMenu',cpMenu);

% axis
pCmAx = axes(cmapPan,'Tag','pCmAx','Box','on',...
    'Units','Pixels','Position',[95,220,165,25],...
    'XTick',[],'YTick',[]);

% min/max text
cm_pMinText = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_pMinText','Position',[10 205 80 15],'FontSize',9);
cm_pMaxText = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_pMaxText','Position',[265 205 80 15],'FontSize',9);

%--------------------
% negative colour map

% enable/disable neg. colmap
addNegCM = uicontrol(cmapPan,'Style','checkbox','String',...
    'Add -ve colormap','Tag','addNegCM','Position',[10 170 300 25]);

% min/max values
cm_nMinEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_nMinEdit','Position',[10 135 80 25]);
cm_nMaxEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_nMaxEdit','Position',[265 135 80 25]);

% axis
nCmAx = axes(cmapPan,'Tag','nCmAx','Box','on',...
    'Units','Pixels','Position',[95,135,165,25],...
    'XTick',[],'YTick',[],'Color',confDataFig.Color);

% min/max text
cm_nMinText = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_nMinText','Position',[10 120 80 15],'FontSize',9);
cm_nMaxText = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_nMaxText','Position',[265 120 80 15],'FontSize',9);

% create group & disable for now
nCM = [cm_nMinEdit,cm_nMaxEdit,cm_nMinText,cm_nMaxText];
set(nCM,'Enable','off');

%---------------------------
% colour limits button group

colLimBG = uibuttongroup(cmapPan,'Tag','colLimBG','Title',...
    'Values outside color range:','BorderType','none',...
    'Units','pixels','Position',[10,10,335,95]);

% map
mapCol = uicontrol(colLimBG,'Style','radiobutton','String',...
    'Map to nearest color','Tag','mapCol','Position',[10 40 300 25]);

% clip
clipCol = uicontrol(colLimBG,'Style','radiobutton','String',...
    'Clip (make transparent)','Tag','clipCol','Position',[10 10 300 25]);

%------------
% auto button
autoBut = uicontrol(cmapPan,'Style','pushbutton','String','Auto',...
    'Tag','autoBut','Position',[265,10,80,25],'Callback','');

%  ========================================================================
%  ---------------------- STATS PANEL -------------------------------------

% panel
statsPan = uipanel(confDataFig,'Tag','statsPan','Title','Stats',...
    'Units','pixels','Position',[15,15,950,240]);

%------------------
% stats data choice

dataChPan = uipanel(statsPan,'Tag','dataChPan','Title','',...
    'Units','pixels','Position',[10,165,335,45]);

% stats data choice
sP(1) = uicontrol(dataChPan,'String','Stats: ',...
    'Tag','sDChTxt','Position',[5 15 55 15]);
dChStEdit = uicontrol(dataChPan,'Style','edit','String','999',...
    'Tag','dChStEdit','Position',[60 10 50 25]);
sP(2) = uicontrol(dataChPan,'String',' / 999',...
    'Tag','pMinTxt','Position',[115 15 50 15]);

% histogram data choice
sP(3) = uicontrol(dataChPan,'String','Hist: ',...
    'Tag','meanTxt','Position',[180 15 50 15]);
dChHiEdit = uicontrol(dataChPan,'Style','edit','String','999',...
    'Tag','dChHiEdit','Position',[230 10 50 25]);
sP(4) = uicontrol(dataChPan,'String',' / 999',...
    'Tag','pMinTxt','Position',[285 15 50 15]);

%------------------
% stats text labels

% various text options
sP(5) = uicontrol(statsPan,'String','Mean: ',...
    'Tag','meanTxt','Position',[10 135 80 15]);
sP(6) = uicontrol(statsPan,'String','Min (+ve): ',...
    'Tag','pMinTxt','Position',[10 105 80 15]);
sP(7) = uicontrol(statsPan,'String','Min (-ve): ',...
    'Tag','nMinTxt','Position',[10 75 80 15]);
sP(8) = uicontrol(statsPan,'String','Other: ',...
    'Tag','othTxt','Position',[10 45 80 15]);
sP(9) = uicontrol(statsPan,'String','Std: ',...
    'Tag','sdTxt','Position',[180 135 80 15]);
sP(10) = uicontrol(statsPan,'String','Max (+ve): ',...
    'Tag','pMaxTxt','Position',[180 105 80 15]);
sP(11) = uicontrol(statsPan,'String','Max (-ve): ',...
    'Tag','nMaxTxt','Position',[180 75 80 15]);

% set constant properties
set(sP,'Style','text','HorizontalAlignment','left','FontSize',10);
clearvars 'sP';

%------------------
% stats edit labels

% various text options
meanEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','meanEdit','Position',[95 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
pMinEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','pMinEdit','Position',[95 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
nMinEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','nMinEdit','Position',[95 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
othEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','othEdit','Position',[265 40 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
sdEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','sdEdit','Position',[265 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
pMaxEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','pMaxEdit','Position',[265 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
nMaxEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','nMaxEdit','Position',[265 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);

%---------------
% 'Other' labels

% other popupmenu
othStats = uicontrol(statsPan,'Style','popupmenu','String',...
    {'Median','SEM','(x)th percentile','(x) % conf. interval',...
    'Mean + (x)*SD', 'Mean + (x)*SEM'},...
    'FontSize',10,'Tag','othStats','Position',[95 40 165 25],...
    'Value',1,'Callback','');

%-----------
% (x) labels

% x text
[~] = uicontrol(statsPan,'Style','text','String','x: ',...
    'HorizontalAlignment','right','FontSize',10,...
    'Tag','xTxt','Position',[40 15 50 15],'Enable','off');

% x edit 
xEdit = uicontrol(statsPan,'Style','edit','String','0.95',...
    'FontSize',10,'Tag','xEdit','Position',[95 10 60 25],...
    'Callback','','Enable','off');

%  ========================================================================
%  ---------------------- THRESHOLDING PANEL ------------------------------

% panel
threshPan = uipanel(confDataFig,'Tag','threshPan','Title','Thresholding',...
    'Units','pixels','Position',[385,265,580,405]);





%  ========================================================================
%  ---------------------- OKAY/CANCEL/PREVIEW -----------------------------

% done button
doneBut = uicontrol(confDataFig,'Style','pushbutton','String','Done',...
    'Tag','doneBut','Position',[975,620,120,30],'BackgroundColor',...
    [46,204,113]/255,'Callback','');

% cancel button
cancBut = uicontrol(confDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[975,580,120,30],...
    'BackgroundColor',[231,76,60]/255,'Callback','');

% preview button
prevBut = uicontrol(confDataFig,'Style','pushbutton','String','Preview',...
    'Tag','prevBut','Position',[975,520,120,30],...
    'Callback','');






