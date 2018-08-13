
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
    'Units','pixels','Position',[100, 100, 1200, 720],'Visible','on',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% grab context menu for copy/paste
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- COLORMAP PANEL ----------------------------------

% panel
cmapPan = uipanel(confDataFig,'Tag','cmapPan','Title','Colormap',...
    'Units','pixels','Position',[15,260,355,275]);

%---------------------------
% positive/normal colour map

% min/max values
cm_pMinEdit = uicontrol(cmapPan,'Style','edit','String','1234.56',...
    'Tag','cm_pMinEdit','Position',[10 220 80 25]);
cm_pMaxEdit = uicontrol(cmapPan,'Style','edit','String','1234.56',...
    'Tag','cm_pMaxEdit','Position',[265 220 80 25]);

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
    'Units','pixels','Position',[15,15,950,235]);

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
    'Tag','meanEdit','Position',[95 130 80 25]);
pMinEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','pMinEdit','Position',[95 100 80 25]);
nMinEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','nMinEdit','Position',[95 70 80 25]);
othEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','othEdit','Position',[265 40 80 25]);
sdEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','sdEdit','Position',[265 130 80 25]);
pMaxEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','pMaxEdit','Position',[265 100 80 25]);
nMaxEdit = uicontrol(statsPan,'Style','edit','String','1234.56',...
    'Tag','nMaxEdit','Position',[265 70 80 25]);

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
    'Callback','','UIContextMenu',cpMenu,'Enable','off');


