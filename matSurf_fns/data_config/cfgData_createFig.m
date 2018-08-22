function [h] = cfgData_createFig


%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
h.confDataFig = figure('Name','Config. data overlay',...
    'Tag','confDataFig','FileName','confData.fig',...
    'Units','pixels','Position',[100, 100, 1055, 670],'Visible','on',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% grab context menus for copy, and copy/paste
cMenu  = copy_paste_menu(0);
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- OPACITY PANEL ----------------------------------

% panel
opacPan = uipanel(h.confDataFig,'Tag','opacPan','Title','Global opacity',...
    'Units','pixels','Position',[15,535,355,120]);

% mask zeros checkbox
h.maskZeros = uicontrol(opacPan,'Style','checkbox','Value',1,'String',...
    'Ignore zeros (0s) in dataset (make transparent)',...
    'Tag','maskZeros','Position',[10 65 330 25]);

% transparency text
[~] = uicontrol(opacPan,'Style','text','String','Transparency',...
    'HorizontalAlignment','left','FontSize',9,...
    'Tag','transText','Position',[10 35 250 15]);

% transparency slider
h.transSlide = uicontrol(opacPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.1,0.2],'Value',1,'Tag','transSlide',...
    'Position',[10 13 270 19]);

% transparency edit
h.transEdit = uicontrol(opacPan,'Style','edit','String','1.00',...
    'FontSize',10,'Tag','transEdit','Position',[285 10 60 25],...
    'UIContextMenu',cpMenu);

%  ========================================================================
%  ---------------------- COLORMAP PANEL ----------------------------------

% panel
cmapPan = uipanel(h.confDataFig,'Tag','cmapPan','Title','Colormap',...
    'Units','pixels','Position',[15,250,355,275]);

%---------------------------
% positive/normal colour map

% min/max values
h.cm_pMinEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_pMinEdit','Position',[10 220 80 25],...
    'UIContextMenu',cpMenu);
h.cm_pMaxEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_pMaxEdit','Position',[265 220 80 25],...
    'UIContextMenu',cpMenu);

% axis
h.pCmAx = axes(cmapPan,'Tag','pCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,220,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% min/max text, cmap name
[~] = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_pMinText','Position',[10 205 80 15],'FontSize',9);
[~] = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_pMaxText','Position',[265 205 80 15],'FontSize',9);
h.cm_pNameText = uicontrol(cmapPan,'Style','text','String','',...
    'Tag','cm_pNameText','Position',[95 205 165 15],'FontSize',9);

%--------------------
% negative colour map

% enable/disable neg. colmap
h.addNegCM = uicontrol(cmapPan,'Style','checkbox','String',...
    'Add -ve colormap','Tag','addNegCM','Position',[10 170 300 25]);

% min/max values
h.cm_nMinEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_nMinEdit','Position',[10 135 80 25]);
h.cm_nMaxEdit = uicontrol(cmapPan,'Style','edit','String','',...
    'Tag','cm_nMaxEdit','Position',[265 135 80 25]);

% axis
h.nCmAx = axes(cmapPan,'Tag','nCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,135,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% min/max text, cmap name
cm_nMinText = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_nMinText','Position',[10 120 80 15],'FontSize',9);
cm_nMaxText = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_nMaxText','Position',[265 120 80 15],'FontSize',9);
h.cm_nNameText = uicontrol(cmapPan,'Style','text','String','',...
    'Tag','cm_nNameText','Position',[95 120 165 15],'FontSize',9);

% create group & disable for now
h.nCM = [h.cm_nMinEdit,h.cm_nMaxEdit,...
    cm_nMinText,cm_nMaxText,h.cm_nNameText];
set(h.nCM,'Enable','off');

%---------------------------
% colour limits button group

h.colLimBG = uibuttongroup(cmapPan,'Tag','colLimBG','Title',...
    'Values outside color range:','BorderType','none',...
    'Units','pixels','Position',[10,10,335,95]);

% map
[~] = uicontrol(h.colLimBG,'Style','radiobutton','String',...
    'Map to nearest color','Tag','mapCol','Position',[10 40 300 25]);

% clip
[~] = uicontrol(h.colLimBG,'Style','radiobutton','String',...
    'Clip (make transparent)','Tag','clipCol','Position',[10 10 300 25]);

%------------
% auto button
h.autoBut = uicontrol(cmapPan,'Style','pushbutton','String','Auto',...
    'Tag','autoBut','Position',[265,10,80,25],'Callback','');

%  ========================================================================
%  ---------------------- STATS PANEL -------------------------------------

% panel
statsPan = uipanel(h.confDataFig,'Tag','statsPan','Title',...
    'Stats + histogram','Units','pixels','Position',[15,15,900,225]);

%------------------
% stats data choice

h.dataChBG = uibuttongroup(statsPan,'Tag','dataChPan','Title','',...
    'BorderType','none','Units','pixels','Position',[15,165,335,35]);

% show for text
sP(1) = uicontrol(h.dataChBG,'String','Show stats for: ',...
    'Tag','DChTxt','Position',[5 10 110 15]);

% data
[~] = uicontrol(h.dataChBG,'Style','radiobutton','String',...
    'Data','Tag','dStats','Position',[120 5 65 25]);

% sig. map
[~] = uicontrol(h.dataChBG,'Style','radiobutton','String',...
    'Significance map','Tag','sStats','Position',[190 5 135 25],...
    'Enable','off');

%------------------
% stats text labels

% various text options
sP(2) = uicontrol(statsPan,'String','Mean: ',...
    'Tag','meanTxt','Position',[10 135 80 15]);
sP(3) = uicontrol(statsPan,'String','Min (+ve): ',...
    'Tag','pMinTxt','Position',[10 105 80 15]);
sP(4) = uicontrol(statsPan,'String','Min (-ve): ',...
    'Tag','nMinTxt','Position',[10 75 80 15]);
sP(5) = uicontrol(statsPan,'String','Other: ',...
    'Tag','othTxt','Position',[10 45 80 15]);
sP(6) = uicontrol(statsPan,'String','Std: ',...
    'Tag','sdTxt','Position',[180 135 80 15]);
sP(7) = uicontrol(statsPan,'String','Max (+ve): ',...
    'Tag','pMaxTxt','Position',[180 105 80 15]);
sP(8) = uicontrol(statsPan,'String','Max (-ve): ',...
    'Tag','nMaxTxt','Position',[180 75 80 15]);

% set constant properties
set(sP,'Style','text','HorizontalAlignment','left','FontSize',10);
clearvars 'sP';

%------------------
% stats edit labels

% various text options
h.meanEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','meanEdit','Position',[95 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.pMinEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','pMinEdit','Position',[95 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.nMinEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','nMinEdit','Position',[95 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.othEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','othEdit','Position',[265 40 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.sdEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','sdEdit','Position',[265 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.pMaxEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','pMaxEdit','Position',[265 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
h.nMaxEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','nMaxEdit','Position',[265 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);

%---------------
% 'Other' labels

% other popupmenu
h.othStats = uicontrol(statsPan,'Style','popupmenu','String',...
    {'Num. nonzeros','Median','SEM','xth percentile','x% conf. interval',...
    'Mean + x*SD', 'Mean + x*SEM', 'TrimMean, excl. x%'},...
    'FontSize',10,'Tag','othStats','Position',[95 40 165 25],...
    'Value',1,'Callback','');

%-----------
% (x) labels

% x text
[~] = uicontrol(statsPan,'Style','text','String','x: ',...
    'HorizontalAlignment','right','FontSize',10,...
    'Tag','xTxt','Position',[40 15 50 15],'Enable','off');

% x edit
h.xEdit = uicontrol(statsPan,'Style','edit','String','',...
    'FontSize',10,'Tag','xEdit','Position',[95 10 80 25],...
    'Callback','','Enable','off');

%----------
% histogram

% create main axis
h.statsAx = axes(statsPan,'Tag','statsAx','Box','on','FontSize',10,...
    'Units','Pixels','Position',[420,30,455,175],'TickLength',[0,0],...
    'NextPlot','add','HitTest','off');

% set ylabel
ylabel(h.statsAx,'Percent','FontSize',10);

% plot bar chart (histogram, but using bar as greater control)
h.stHist = bar(h.statsAx,nan,nan,'BarWidth',1,...
    'FaceColor','flat','LineStyle','none','Tag','stHist');

% plot line
h.stPlot = line(h.statsAx,'XData',[],'YData',[],'Color','k',...
    'LineWidth',1.5,'LineStyle','--','Tag','stPlot');

%  ========================================================================
%  ---------------------- THRESHOLDING PANEL ------------------------------

% panel
threshPan = uipanel(h.confDataFig,'Tag','threshPan','Title',...
    'Thresholding - local opacity','Units','pixels',...
    'Position',[385,250,530,405]);

%------------------------
% threshold based on text

h.thrChBG = uibuttongroup(threshPan,'Tag','thrChBG','Title','',...
    'BorderType','none','Units','pixels','Position',[15,345,365,35]);

% text
[~] = uicontrol(h.thrChBG,'Style','text','HorizontalAlignment','left',...
    'FontSize',10,'String','Threshold based on: ',...
    'Tag','thrText','Position',[5 10 145 15]);

% data
[~] = uicontrol(h.thrChBG,'Style','radiobutton','String',...
    'Data','Tag','dThr','Position',[155 5 65 25]);

% sig. map
[~] = uicontrol(h.thrChBG,'Style','radiobutton','String',...
    'Significance map','Tag','sThr','Position',[225 5 135 25],...
    'Enable','off');

% -------------------------------
% load in threshold button images

thrPics = load('thrPics.mat');
h.thrPics = thrPics.thrPics;

% set white (255) to whatever background colour of figure is
colDif = round(255 - mean(h.confDataFig.Color)*255);
h.thrPics = h.thrPics - colDif;

%----------------------------
% Filter - normal or reversed

h.normReVFiltBG = uibuttongroup(threshPan,'Tag','normReVFiltBG',...
    'Title','Filter','Units','pixels','Position',[10,185,70,150]);

% normal filter
h.normFilt = uicontrol(h.normReVFiltBG,'Style','togglebutton',...
    'String','','Tag','normFilt','Position',[10 70 50 50],'UserData',1,...
    'CData',squeeze(h.thrPics(1,1,1,:,:,:)));

% reverse filter
h.revFilt = uicontrol(h.normReVFiltBG,'Style','togglebutton',...
    'String','','Tag','revFilt','Position',[10 10 50 50],'UserData',2,...
    'CData',squeeze(h.thrPics(2,1,1,:,:,:)));

%--------------------------------------------
% Filter type - absolute, gradient, sigmoidal

h.typeFiltBG = uibuttongroup(threshPan,'Tag','typeFiltBG',...
    'Title','Filter type','Units','pixels','Position',[90,280,310,55]);

% absolute filter
h.absFilt = uicontrol(h.typeFiltBG,'Style','radiobutton',...
    'String','Absolute','Tag','absFilt','Position',[10 10 90 25],'UserData',1);

% gradient filter
h.gradFilt = uicontrol(h.typeFiltBG,'Style','radiobutton',...
    'String','Gradient','Tag','gradFilt','Position',[110 10 90 25],'UserData',2);

% sigmoidal filter
h.sigFilt = uicontrol(h.typeFiltBG,'Style','radiobutton',...
    'String','Sigmoid','Tag','sigFilt','Position',[210 10 90 25],'UserData',3);

%--------------------------
% Num. filters - one or two

h.numFiltBG = uibuttongroup(threshPan,'Tag','numFiltBG',...
    'Title','# Filters','Units','pixels','Position',[410,280,110,55]);

% one filter
h.oneFilt = uicontrol(h.numFiltBG,'Style','radiobutton',...
    'String','1','Tag','oneFilt','Position',[10 10 40 25],'UserData',1);

% two filters
h.twoFilt = uicontrol(h.numFiltBG,'Style','radiobutton',...
    'String','2','Tag','twoFilt','Position',[60 10 40 25],'UserData',2);

%----------------
% Threshold range

h.thrRngBG = uibuttongroup(threshPan,'Tag','thrRngBG','Title','Threshold range',...
    'Units','pixels','Position',[90,185,430,90]);

% set text colors
thrTxtCol = [0.90,0.30,0.25;...
    0.55,0.25,0.70;...
    0.15,0.50,0.70;...
    0.15,0.70,0.40];

% text labels
h.f1_lTxt = uicontrol(h.thrRngBG,'String','Filter 1 - (a1): ',...
    'Tag','f1_lTxt','Position',[20 45 100 15],...
    'ForegroundColor',thrTxtCol(1,:));
h.f1_hTxt = uicontrol(h.thrRngBG,'String','Filter 1 - (b1): ',...
    'Tag','f1_hTxt','Position',[20 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(2,:));
h.f2_lTxt = uicontrol(h.thrRngBG,'String','Filter 2 - (a2): ',...
    'Tag','f2_lTxt','Position',[225 45 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(3,:));
h.f2_hTxt = uicontrol(h.thrRngBG,'String','Filter 2 - (b2): ',...
    'Tag','f2_hTxt','Position',[225 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(4,:));

% set constant properties
set([h.f1_lTxt,h.f1_hTxt,h.f2_lTxt,h.f2_hTxt],...
    'Style','text','HorizontalAlignment','left','FontSize',10);

% edit buttons
h.f1_lEdit = uicontrol(h.thrRngBG,'Style','edit','String','',...
    'Tag','f1_lEdit','Position',[125 40 80 25]);
h.f1_hEdit = uicontrol(h.thrRngBG,'Style','edit','String','',...
    'Tag','f1_hEdit','Position',[125 10 80 25],...
    'Enable','off');
h.f2_lEdit = uicontrol(h.thrRngBG,'Style','edit','String','',...
    'Tag','f2_lEdit','Position',[330 40 80 25],...
    'Enable','off');
h.f2_hEdit = uicontrol(h.thrRngBG,'Style','edit','String','',...
    'Tag','f2_hEdit','Position',[330 10 80 25],...
    'Enable','off');

%--------------
% axis and plot

% create main axis
h.thrAx = axes(threshPan,'Tag','thrAx','Box','on','FontSize',10,...
    'Units','Pixels','Position',[50,30,455,145],'YLim',[-0.1,1.1],...
    'YTick',[0,0.5,1],'TickLength',[0,0],'YTickLabel',{'0','.5','1'},...
    'NextPlot','add','HitTest','off');

% set ylabel
ylabel(h.thrAx,'Opacity','FontSize',10);

% plot line
h.thrPlot = line(h.thrAx,'XData',[],'YData',[],'LineWidth',1,'Tag','thrPlot');

% create lines for filter values
h.thrFilt_a1 = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_a1');
h.thrFilt_a2 = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_a2');
h.thrFilt_b1 = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_b1');
h.thrFilt_b2 = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_b2');

%  ========================================================================
%  ---------------------- OKAY/CANCEL/PREVIEW -----------------------------

% done button
h.doneBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Done',...
    'Tag','doneBut','Position',[925,605,120,30],'BackgroundColor',...
    [46,204,113]/255,'Callback','');

% cancel button
h.cancBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[925,565,120,30],...
    'BackgroundColor',[231,76,60]/255,'Callback','');

% preview button
h.prevBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Preview',...
    'Tag','prevBut','Position',[925,505,120,30],...
    'Callback','');

end



