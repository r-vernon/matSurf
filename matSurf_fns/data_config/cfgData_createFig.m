function [h] = cfgData_createFig


%%  =======================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
h.confDataFig = figure('Name','Config. data overlay',...
    'Tag','confDataFig','FileName','confData.fig',...
    'Units','pixels','Position',[100, 100, 1055, 670],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% Move the window to the center of the screen.
movegui(h.confDataFig,'center');

% grab context menus for copy, and copy/paste
h.cMenu  = copy_paste_menu(0);
h.cpMenu = copy_paste_menu;

%%  =======================================================================
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
    'UIContextMenu',h.cpMenu);

%%  =======================================================================
%  ---------------------- COLORMAP PANEL ----------------------------------

% panel
cmapPan = uipanel(h.confDataFig,'Tag','cmapPan','Title','Colormap',...
    'Units','pixels','Position',[15,250,355,275]);

% create temporary blank colormap, same size as axis
blankCmap = ones(25,165,3,'uint8')*255;

%---------------------------
% positive/normal colour map

% min/max values
h.cm_pMinEdit = uicontrol(cmapPan,'Style','edit','String','nan',...
    'Tag','cm_pMinEdit','Position',[10 220 80 25],...
    'UIContextMenu',h.cpMenu);
h.cm_pMaxEdit = uicontrol(cmapPan,'Style','edit','String','nan',...
    'Tag','cm_pMaxEdit','Position',[265 220 80 25],...
    'UIContextMenu',h.cpMenu);

% axis
h.pCmAx = axes(cmapPan,'Tag','pCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,220,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% colormap image
h.pCmap = image(h.pCmAx,'XData',[0,1],'YData',[0,1],'CData',blankCmap,'Tag','pCmap');

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
h.cm_nMinEdit = uicontrol(cmapPan,'Style','edit','String','nan',...
    'Tag','cm_nMinEdit','Position',[10 135 80 25]);
h.cm_nMaxEdit = uicontrol(cmapPan,'Style','edit','String','nan',...
    'Tag','cm_nMaxEdit','Position',[265 135 80 25]);

% axis
h.nCmAx = axes(cmapPan,'Tag','nCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,135,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% colormap image
h.nCmap = image(h.nCmAx,'XData',[0,1],'YData',[0,1],'CData',blankCmap,'Tag','nCmap',...
    'AlphaData',0.2);

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
h.mapCol = uicontrol(h.colLimBG,'Style','radiobutton','String',...
    'Map to nearest color','Tag','mapCol','Position',[10 40 300 25]);

% clip
h.clipCol = uicontrol(h.colLimBG,'Style','radiobutton','String',...
    'Clip (make transparent)','Tag','clipCol','Position',[10 10 300 25]);

%------------
% auto button
h.autoBut = uicontrol(cmapPan,'Style','pushbutton','String','Auto',...
    'Tag','autoBut','Position',[265,10,80,25]);

%%  =======================================================================
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
h.dStats = uicontrol(h.dataChBG,'Style','radiobutton','String',...
    'Data','Tag','dStats','Position',[120 5 65 25]);

% sig. map
h.sStats = uicontrol(h.dataChBG,'Style','radiobutton','String',...
    'Significance map','Tag','sStats','Position',[190 5 135 25],...
    'Enable','off');

%------------------
% stats text labels

% various text options
sP(2) = uicontrol(statsPan,'String','Mean: ',...
    'Tag','meanTxt','Position',[10 135 80 15]);
sP(3) = uicontrol(statsPan,'String','Min (-ve): ',...
    'Tag','nMinTxt','Position',[10 105 80 15]);
sP(4) = uicontrol(statsPan,'String','Max (-ve): ',...
    'Tag','nMaxTxt','Position',[10 75 80 15]);
sP(5) = uicontrol(statsPan,'String','Other: ',...
    'Tag','othTxt','Position',[10 45 80 15]);
sP(6) = uicontrol(statsPan,'String','Std: ',...
    'Tag','sdTxt','Position',[180 135 80 15]);
sP(7) = uicontrol(statsPan,'String','Max (+ve): ',...
    'Tag','pMaxTxt','Position',[180 105 80 15]);
sP(8) = uicontrol(statsPan,'String','Min (+ve): ',...
    'Tag','pMinTxt','Position',[180 75 80 15]);

% set constant properties
set(sP,'Style','text','HorizontalAlignment','left','FontSize',10);
clearvars 'sP';

%------------------
% stats edit labels

% various text options
h.meanEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','meanEdit','Position',[95 130 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.nMinEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','nMinEdit','Position',[95 100 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.nMaxEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','nMaxEdit','Position',[95 70 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.othEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','othEdit','Position',[265 40 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.sdEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','sdEdit','Position',[265 130 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.pMaxEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','pMaxEdit','Position',[265 100 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);
h.pMinEdit = uicontrol(statsPan,'Style','edit','String','',...
    'Tag','pMinEdit','Position',[265 70 80 25],...
    'Enable','inactive','UIContextMenu',h.cMenu);

%---------------
% 'Other' labels

% other popupmenu (userdata stores fieldnames)
h.othStats = uicontrol(statsPan,'Style','popupmenu','String',...
    {'Num. nonzeros','Median','SEM','xth percentile','x% conf. interval',...
    'Mean + x*SD', 'Mean + x*SEM', 'TrimMean, excl. x%'},'FontSize',10,...
    'Tag','othStats','Position',[95 40 165 25],'Value',1,'UserData',...
    {'nnz','med','SEM','prctile','CI','meanPlusSD','meanPlusSEM','trMean'});

%-----------
% (x) labels

% x text
h.xTxt = uicontrol(statsPan,'Style','text','String','x: ',...
    'HorizontalAlignment','right','FontSize',10,...
    'Tag','xTxt','Position',[40 15 50 15],'Enable','off');

% x edit
h.xEdit = uicontrol(statsPan,'Style','edit','String','',...
    'FontSize',10,'Tag','xEdit','Position',[95 10 80 25],...
    'Enable','off');

% x guide
h.xGuideTxt = uicontrol(statsPan,'Style','text','String','(1 - 99)',...
    'HorizontalAlignment','left','FontSize',10,...
    'Tag','xGuideTxt','Position',[180 15 80 15],'Visible','off');

%----------
% histogram

% create main axis
h.statsAx = axes(statsPan,'Tag','statsAx','Box','on','FontSize',10,...
    'Units','Pixels','Position',[410,30,465,175],...
    'YTick',[],'YTickLabel','','TickLength',[0,0],...
    'Layer','top','NextPlot','add','HitTest','off');

% set ylabel
ylabel(h.statsAx,'Frequency','FontSize',10);

%---------------------
% histogram background

chSize = 5;
whCh = ones(chSize,'uint8');
grCh = whCh*215;
whCh = whCh*255;

chSq = [grCh,whCh; whCh, grCh];
chIm = repmat(repmat(chSq,...
    [1,ceil(h.statsAx.Position(3)/(2*chSize))]),...
    [ceil(h.statsAx.Position(4)/(2*chSize)),1]);
chIm = chIm(:,1:h.statsAx.Position(3));
chIm = chIm(1:h.statsAx.Position(4),:);
chIm = repmat(chIm,[1,1,3]);

h.statsAxBG = image(h.statsAx,'XData',h.statsAx.XLim,'YData',h.statsAx.YLim,...
    'CData',chIm,'Tag','statsAxBG');

%----------------
% histogram plots

% plot bar chart (histogram, but using bar as greater control)
h.stHist = patch(h.statsAx,'Faces',[],'Vertices',[],'Tag','stHist',...
    'FaceAlpha','interp','AlphaDataMapping','none',...
    'FaceColor', 'interp','EdgeColor','none');

% plot line
h.stPlot = line(h.statsAx,'XData',[],'YData',[],'Color','k',...
    'LineWidth',1,'Tag','stPlot');

%-----------------------
% edit axis limits panel

histXLimPan = uipanel(h.confDataFig,'Tag','histXLimPan','Title',...
    'Histogram','Units','pixels','Position',[925,15,100,190]);

h.histLogX = uicontrol(histXLimPan,'Style','checkbox',...
    'String','log10(x)','Tag','histLogX',...
    'Position',[10 135 80 25],'Enable','off');

[~] = uicontrol(histXLimPan,'Style','text','String','XLim:',...
    'HorizontalAlignment','left','FontSize',9,'Tag','histXLimText',...
    'Position',[10 115 80 15]);

h.histXLim1Edit = uicontrol(histXLimPan,'Style','edit','String','',...
    'Tag','histXLim1Edit','Position',[10 90 80 25],'UIContextMenu',h.cpMenu);
h.histXLim2Edit = uicontrol(histXLimPan,'Style','edit','String','',...
    'Tag','histXLim2Edit','Position',[10 60 80 25],'UIContextMenu',h.cpMenu);

[~] = uicontrol(histXLimPan,'Style','text','String','nBins:',...
    'HorizontalAlignment','left','FontSize',9,'Tag','histNBinsText',...
    'Position',[10 35 80 15]);

h.histNBinsEdit = uicontrol(histXLimPan,'Style','edit','String','',...
    'Tag','histNBinsEdit','Position',[10 10 80 25],'UIContextMenu',h.cpMenu);

%%  =======================================================================
%  ---------------------- THRESHOLDING PANEL ------------------------------

% panel
threshPan = uipanel(h.confDataFig,'Tag','threshPan','Title',...
    'Thresholding - local opacity','Units','pixels',...
    'Position',[385,250,530,405]);

%------------------------
% threshold based on text

h.thrChBG = uibuttongroup(threshPan,'Tag','thrChBG','Title','',...
    'BorderType','none','Units','pixels','Position',[15,345,500,35]);

% text
[~] = uicontrol(h.thrChBG,'Style','text','HorizontalAlignment','left',...
    'FontSize',10,'String','Threshold based on: ',...
    'Tag','thrText','Position',[5 10 145 15]);

% data
h.dThr = uicontrol(h.thrChBG,'Style','radiobutton','String',...
    'Data','Tag','dThr','Position',[155 5 65 25]);

% sig. map
h.sThr = uicontrol(h.thrChBG,'Style','radiobutton','String',...
    'Significance map','Tag','sThr','Position',[225 5 135 25],...
    'Enable','off');

% use log(x)
h.logThr = uicontrol(h.thrChBG,'Style','checkbox',...
    'String','Use log10(x)','Tag','logThr',...
    'Position',[380 5 120 25],'Enable','off');

% -------------------------------
% load in threshold button images

thrPics = load('thrPics.mat');
h.thrPics = thrPics.thrPics;

% set white (255) to whatever background colour of figure is
colDif = round(255 - mean(h.confDataFig.Color)*255);
h.thrPics = h.thrPics - colDif;

%----------------------------
% Filter - normal or reversed

h.normRevFiltBG = uibuttongroup(threshPan,'Tag','normRevFiltBG',...
    'Title','Filter','Units','pixels','Position',[10,185,70,150]);

% normal filter
h.normFilt = uicontrol(h.normRevFiltBG,'Style','togglebutton',...
    'String','','Tag','normFilt','Position',[10 70 50 50],'UserData',1,...
    'CData',squeeze(h.thrPics(1,1,1,:,:,:)));

% reverse filter
h.revFilt = uicontrol(h.normRevFiltBG,'Style','togglebutton',...
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
h.f1_lTxt = uicontrol(h.thrRngBG,'String','Filter 1 - (1a): ',...
    'Tag','f1_lTxt','Position',[20 45 100 15],...
    'ForegroundColor',thrTxtCol(1,:));
h.f1_hTxt = uicontrol(h.thrRngBG,'String','Filter 1 - (1b): ',...
    'Tag','f1_hTxt','Position',[20 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(2,:));
h.f2_lTxt = uicontrol(h.thrRngBG,'String','Filter 2 - (2a): ',...
    'Tag','f2_lTxt','Position',[225 45 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(3,:));
h.f2_hTxt = uicontrol(h.thrRngBG,'String','Filter 2 - (2b): ',...
    'Tag','f2_hTxt','Position',[225 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(4,:));

% set constant properties
set([h.f1_lTxt,h.f1_hTxt,h.f2_lTxt,h.f2_hTxt],...
    'Style','text','HorizontalAlignment','left','FontSize',10);

% edit buttons
h.f1_lEdit = uicontrol(h.thrRngBG,'Style','edit','String','',...
    'Tag','f1_lEdit','Position',[125 40 80 25],'UIContextMenu',h.cpMenu);
h.f1_hEdit = uicontrol(h.thrRngBG,'Style','edit','String','nan',...
    'Tag','f1_hEdit','Position',[125 10 80 25],'Enable','off');
h.f2_lEdit = uicontrol(h.thrRngBG,'Style','edit','String','nan',...
    'Tag','f2_lEdit','Position',[330 40 80 25],'Enable','off');
h.f2_hEdit = uicontrol(h.thrRngBG,'Style','edit','String','nan',...
    'Tag','f2_hEdit','Position',[330 10 80 25],'Enable','off');

%--------------
% axis and plot

% create main axis
h.thrAx = axes(threshPan,'Tag','thrAx','Box','on','FontSize',10,...
    'Units','Pixels','Position',[40,30,465,145],'YLim',[-0.1,1.1],...
    'YLimMode','manual','YTick',[],'YTickLabel','','TickLength',[0,0],...
    'Layer','top','NextPlot','add','HitTest','off');

% set ylabel
ylabel(h.thrAx,'Opacity (0:1)','FontSize',10);

%---------------------
% threshold background

% create checkIm as above (stats background), but double
chIm = repmat(repmat(double(chSq),...
    [1,ceil(h.statsAx.Position(3)/(2*chSize))]),...
    [ceil(h.statsAx.Position(4)/(2*chSize)),1]);
chIm = chIm(:,1:h.statsAx.Position(3));
chIm = chIm(1:h.statsAx.Position(4),:);

% set transparency vertically
chImTransp = linspace(-0.1,1.1,h.statsAx.Position(4))';
chImTransp(chImTransp > 1) = 1;
chImTransp(chImTransp < 0) = 0;
chImTransp = repmat(chImTransp,[1,h.statsAx.Position(3)]);
baseImg = repmat(255,size(chIm)) .* chImTransp;
chIm = chIm .* (1-chImTransp);
chIm = uint8(baseImg + chIm);

chIm = repmat(chIm,[1,1,3]);

h.thrAxBG = image(h.thrAx,'XData',h.thrAx.XLim,'YData',h.thrAx.YLim,...
    'CData',chIm,'Tag','thrAxBG');

%----------------
% threshold plots

% plot line
h.thrPlot = line(h.thrAx,'XData',[],'YData',[],'LineWidth',1,'Tag','thrPlot');

% create lines for filter values
h.thrFilt_1a = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_1a');
h.thrFilt_2a = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_2a');
h.thrFilt_1b = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_1b');
h.thrFilt_2b = line(h.thrAx,'XData',[],'YData',[],'LineStyle','-',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_2b');

%-----------------------
% edit axis limits panel

thrXLimPan = uipanel(h.confDataFig,'Tag','thrAxLimPan','Title',...
    'Thr. Graph','Units','pixels','Position',[925,250,100,140]);

h.thrLogX = uicontrol(thrXLimPan,'Style','checkbox',...
    'String','log10(x)','Tag','thrLogX',...
    'Position',[10 85 80 25],'Enable','off');

[~] = uicontrol(thrXLimPan,'Style','text','String','XLim:',...
    'HorizontalAlignment','left','FontSize',9,'Tag','thrXLimText',...
    'Position',[10 65 80 15]);

h.thrXLim1Edit = uicontrol(thrXLimPan,'Style','edit','String','',...
    'Tag','thrXLim1Edit','Position',[10 40 80 25],'UIContextMenu',h.cpMenu);
h.thrXLim2Edit = uicontrol(thrXLimPan,'Style','edit','String','',...
    'Tag','thrXLim2Edit','Position',[10 10 80 25],'UIContextMenu',h.cpMenu);

%%  =======================================================================
%  ---------------------- OKAY/CANCEL/PREVIEW -----------------------------

% done button
h.doneBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Done',...
    'Tag','doneBut','Position',[925,605,120,30],'BackgroundColor',...
    [46,204,113]/255);

% cancel button
h.cancBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[925,565,120,30],...
    'BackgroundColor',[231,76,60]/255);

% preview button
h.prevBut = uicontrol(h.confDataFig,'Style','pushbutton','String','Preview',...
    'Tag','prevBut','Position',[925,505,120,30]);

%% ========================================================================

%  ---------------------- POINTER MANAGER ---------------------------------

%  ========================================================================

% find handles want to show 'hand' over (popupmenus don't work...)
clickObj = findall(h.confDataFig,'Style','radiobutton','-or','Style',...
    'checkbox','-or','Style','pushbutton','-or','Style','togglebutton');

% add stats edit textboxes to that, as can't change those
clickObj = [clickObj; h.meanEdit; h.nMinEdit; h.nMaxEdit; h.othEdit; ...
    h.sdEdit; h.pMaxEdit; h.pMinEdit];

% whenever text hovers over button, change to hand
enterFcn = @(fig,~) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior(clickObj, enterFcn);

% create a pointer manager
iptPointerManager(h.confDataFig);

end




