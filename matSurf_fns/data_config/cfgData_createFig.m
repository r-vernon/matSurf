
% first, just clear any persistent variables in createThrMask to be safe
clear cfgData_createThrMask;

% create test data
ovrlayName = 'my overlay';
data = normrnd(0,1,[1e4,1]);

% get val. datapoints
valData = nonzeros(data);

% set the initial values for e.g. 'xth percentile' stats options
% in order: prctile, CI, SD, SEM, trimmean
descrInit.prctile = 95;
descrInit.CI      = 95;
descrInit.SD      = 2;
descrInit.SEM     = 1.96;
descrInit.trMean  = 10;

% get some descriptive stats
descr.mean      = mean(valData); 
descr.SD        = std(valData); 
descr.nnz       = numel(valData);
descr.med       = median(valData);
descr.SEM       = descr.SD/sqrt(descr.nnz);
descr.ptile95   = prctile(valData,[5,95]); % get 5th/95th prctile to use as data range
descr.prctile   = descr.ptile95(2);
descr.CI        = descr.mean + norminv(0.5 + descrInit.CI/200)*descr.SEM;
descr.meanPlSD  = descr.mean + descrInit.SD*descr.SD;
descr.meanPlSEM = descr.mean + descrInit.SEM*descr.SEM;
descr.trMean    = trimmean(valData,descrInit.trMean);

% set min/max
descr.MinMax = [min(valData); max(valData)];
if descr.MinMax(1) > 0 % no neg. vals
    descr.negMinMax = [nan; nan];
    descr.posMinMax = descr.MinMax;
elseif descr.MinMax(2) < 0 % no pos. vals
    descr.negMinMax = descr.MinMax;
    descr.posMinMax = [nan; nan];
else
    descr.negMinMax = [descr.MinMax(1); max(valData(valData < 0))];
    descr.posMinMax = [min(valData(valData > 0)); descr.MinMax(2)];
end

%--------------------------------------------------------------------------
% for now hardcode thresholding for createThrMask

% preallocate thresh code
thrCode = [1,1,1];

% preallocate thrVals (order: a1, b1, a2, b2)
thrVals = nan(4,1);
thrVals(1) = descr.MinMax(1);

%--------------------------------------------------------------------------

% grab a colormap for now
tmpCmap = cmaps;
pCmapName = 'heat';
nCmapName = 'cool';

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
confDataFig = figure('Name',sprintf('Config. %s data overlay',ovrlayName),...
    'Tag','confDataFig','FileName','confData.fig',...
    'Units','pixels','Position',[100, 100, 1055, 670],'Visible','on',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% grab context menus for copy, and copy/paste
cMenu  = copy_paste_menu(0);
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- OPACITY PANEL ----------------------------------

% panel
opacPan = uipanel(confDataFig,'Tag','opacPan','Title','Global opacity',...
    'Units','pixels','Position',[15,535,355,120]);

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
    'Units','pixels','Position',[15,250,355,275]);

%---------------------------
% positive/normal colour map

% min/max values
cm_pMinEdit = uicontrol(cmapPan,'Style','edit','String',...
    sprintf('%.2f',descr.MinMax(1)),'Tag','cm_pMinEdit',...
    'Position',[10 220 80 25],'UIContextMenu',cpMenu);
cm_pMaxEdit = uicontrol(cmapPan,'Style','edit','String',...
    sprintf('%.2f',descr.MinMax(2)),'Tag','cm_pMaxEdit',...
    'Position',[265 220 80 25],'UIContextMenu',cpMenu);

% axis
pCmAx = axes(cmapPan,'Tag','pCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,220,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% min/max text, cmap name
cm_pMinText = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_pMinText','Position',[10 205 80 15],'FontSize',9);
cm_pMaxText = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_pMaxText','Position',[265 205 80 15],'FontSize',9);
cm_pNameText = uicontrol(cmapPan,'Style','text','String',pCmapName,...
    'Tag','cm_pNameText','Position',[95 205 165 15],'FontSize',9);

%---------------------------------
% positive/normal colour map image

posCmap = uint8(tmpCmap.getColVals(linspace(0,1,pCmAx.Position(3)),pCmapName)*255);
posCmap = permute(repmat(posCmap,1,1,pCmAx.Position(4)),[3,1,2]);
pCmap = image(pCmAx,'XData',[0,1],'YData',[0,1],'CData',posCmap,'Tag','pCmap');

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
nCmAx = axes(cmapPan,'Tag','nCmAx','Box','on','Layer','top',...
    'Units','Pixels','Position',[95,135,165,25],...
    'XTick',[],'YTick',[],'XLim',[0,1],'YLim',[0,1]);

% min/max text, cmap name
cm_nMinText = uicontrol(cmapPan,'Style','text','String','Min',...
    'Tag','cm_nMinText','Position',[10 120 80 15],'FontSize',9);
cm_nMaxText = uicontrol(cmapPan,'Style','text','String','Max',...
    'Tag','cm_nMaxText','Position',[265 120 80 15],'FontSize',9);
cm_nNameText = uicontrol(cmapPan,'Style','text','String',nCmapName,...
    'Tag','cm_nNameText','Position',[95 120 165 15],'FontSize',9);

% create group & disable for now
nCM = [cm_nMinEdit,cm_nMaxEdit,cm_nMinText,cm_nMaxText,cm_nNameText];
set(nCM,'Enable','off');

%--------------------------
% negative colour map image

negCmap = uint8(tmpCmap.getColVals(linspace(0,1,nCmAx.Position(3)),nCmapName)*255);
negCmap = permute(repmat(negCmap,1,1,nCmAx.Position(4)),[3,1,2]);
nCmap = image(nCmAx,'XData',[0,1],'YData',[0,1],'CData',negCmap,'Tag','nCmap',...
    'AlphaData',0.2);

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
    'Units','pixels','Position',[15,15,900,225]);

%------------------
% stats data choice

dataChBG = uibuttongroup(statsPan,'Tag','dataChPan','Title','',...
    'BorderType','none','Units','pixels','Position',[15,165,335,35]);

% show for text
sP(1) = uicontrol(dataChBG,'String','Show stats for: ',...
    'Tag','DChTxt','Position',[5 10 110 15]);

% data
dStats = uicontrol(dataChBG,'Style','radiobutton','String',...
    'Data','Tag','dStats','Position',[120 5 65 25]);

% sig. map
sStats = uicontrol(dataChBG,'Style','radiobutton','String',...
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
meanEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.mean),...
    'Tag','meanEdit','Position',[95 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
pMinEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.posMinMax(1)),...
    'Tag','pMinEdit','Position',[95 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
nMinEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.negMinMax(1)),...
    'Tag','nMinEdit','Position',[95 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
othEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.nnz),...
    'Tag','othEdit','Position',[265 40 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
sdEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.SD),...
    'Tag','sdEdit','Position',[265 130 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
pMaxEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.posMinMax(2)),...
    'Tag','pMaxEdit','Position',[265 100 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);
nMaxEdit = uicontrol(statsPan,'Style','edit','String',sprintf('%.2f',descr.negMinMax(2)),...
    'Tag','nMaxEdit','Position',[265 70 80 25],...
    'Enable','inactive','UIContextMenu',cMenu);

%---------------
% 'Other' labels

% other popupmenu
othStats = uicontrol(statsPan,'Style','popupmenu','String',...
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
xEdit = uicontrol(statsPan,'Style','edit','String','0.95',...
    'FontSize',10,'Tag','xEdit','Position',[95 10 80 25],...
    'Callback','','Enable','off');

%  ========================================================================
%  ---------------------- THRESHOLDING PANEL ------------------------------

% panel
threshPan = uipanel(confDataFig,'Tag','threshPan','Title',...
    'Thresholding - local opacity','Units','pixels',...
    'Position',[385,250,530,405]);

%------------------------
% threshold based on text

thrChBG = uibuttongroup(threshPan,'Tag','thrChBG','Title','',...
    'BorderType','none','Units','pixels','Position',[15,345,365,35]);

% text
thrText = uicontrol(thrChBG,'Style','text','HorizontalAlignment','left',...
    'FontSize',10,'String','Threshold based on: ',...
    'Tag','thrText','Position',[5 10 145 15]);

% data
dThr = uicontrol(thrChBG,'Style','radiobutton','String',...
    'Data','Tag','dThr','Position',[155 5 65 25]);

% sig. map
sThr = uicontrol(thrChBG,'Style','radiobutton','String',...
    'Significance map','Tag','sThr','Position',[225 5 135 25],...
    'Enable','off');

% ------------------------------- 
% load in threshold button images

thrPics = load('thrPics.mat');
thrPics = thrPics.thrPics;

% set white (255) to whatever background colour of figure is
colDif = round(255 - mean(confDataFig.Color)*255);
thrPics = thrPics - colDif;

%----------------------------
% Filter - normal or reversed

normReVFiltBG = uibuttongroup(threshPan,'Tag','normReVFiltBG','Title','Filter',...
    'Units','pixels','Position',[10,185,70,150]);

% normal filter
normFilt = uicontrol(normReVFiltBG,'Style','togglebutton','String','',...
    'Tag','normFilt','Position',[10 70 50 50],'UserData',1,'CData'...
    ,squeeze(thrPics(1,1,1,:,:,:)));

% reverse filter
revFilt = uicontrol(normReVFiltBG,'Style','togglebutton','String','',...
    'Tag','revFilt','Position',[10 10 50 50],'UserData',2,...
    'CData',squeeze(thrPics(2,1,1,:,:,:)));

% set value
if thrCode(1) == 1, normFilt.Value = 1;
else, revFilt.Value = 1;
end

%--------------------------------------------
% Filter type - absolute, gradient, sigmoidal

typeFiltBG = uibuttongroup(threshPan,'Tag','typeFiltBG','Title','Filter type',...
    'Units','pixels','Position',[90,280,310,55]);

% absolute filter
absFilt = uicontrol(typeFiltBG,'Style','radiobutton','String','Absolute',...
    'Tag','absFilt','Position',[10 10 90 25],'UserData',1);

% gradient filter
gradFilt = uicontrol(typeFiltBG,'Style','radiobutton','String','Gradient',...
    'Tag','gradFilt','Position',[110 10 90 25],'UserData',2);

% sigmoidal filter
sigFilt = uicontrol(typeFiltBG,'Style','radiobutton','String','Sigmoid',...
    'Tag','sigFilt','Position',[210 10 90 25],'UserData',3);

% set value
if thrCode(2) == 1, absFilt.Value = 1;
elseif thrCode(2) == 2, gradFilt.Value = 1;
else, sigFilt.Value = 1;
end

%--------------------------
% Num. filters - one or two

numFiltBG = uibuttongroup(threshPan,'Tag','numFiltBG','Title','# Filters',...
    'Units','pixels','Position',[410,280,110,55]);

% one filter
oneFilt = uicontrol(numFiltBG,'Style','radiobutton','String','1',...
    'Tag','oneFilt','Position',[10 10 40 25],'UserData',1);

% two filters
twoFilt = uicontrol(numFiltBG,'Style','radiobutton','String','2',...
    'Tag','twoFilt','Position',[60 10 40 25],'UserData',2);

% set value
if thrCode(3) == 1, oneFilt.Value = 1;
else, twoFilt.Value = 1;
end

%----------------
% Threshold range

thrRngBG = uibuttongroup(threshPan,'Tag','thrRngBG','Title','Threshold range',...
    'Units','pixels','Position',[90,185,430,90]);

% set text colors
thrTxtCol = [0.90,0.30,0.25;...
    0.55,0.25,0.70;...
    0.15,0.50,0.70;...
    0.15,0.70,0.40];

% text labels
f1_lTxt = uicontrol(thrRngBG,'String','Filter 1 - (a1): ',...
    'Tag','f1_lTxt','Position',[20 45 100 15],...
    'ForegroundColor',thrTxtCol(1,:));
f1_hTxt = uicontrol(thrRngBG,'String','Filter 1 - (b1): ',...
    'Tag','f1_hTxt','Position',[20 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(2,:));
f2_lTxt = uicontrol(thrRngBG,'String','Filter 2 - (a2): ',...
    'Tag','f2_lTxt','Position',[225 45 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(3,:));
f2_hTxt = uicontrol(thrRngBG,'String','Filter 2 - (b2): ',...
    'Tag','f2_hTxt','Position',[225 15 100 15],...
    'Enable','off','ForegroundColor',thrTxtCol(4,:));

% set constant properties
set([f1_lTxt,f1_hTxt,f2_lTxt,f2_hTxt],...
    'Style','text','HorizontalAlignment','left','FontSize',10);

% edit buttons
f1_lEdit = uicontrol(thrRngBG,'Style','edit','String','',...
    'Tag','f1_lEdit','Position',[125 40 80 25]);
f1_hEdit = uicontrol(thrRngBG,'Style','edit','String','',...
    'Tag','f1_hEdit','Position',[125 10 80 25],...
    'Enable','off');
f2_lEdit = uicontrol(thrRngBG,'Style','edit','String','',...
    'Tag','f2_lEdit','Position',[330 40 80 25],...
    'Enable','off');
f2_hEdit = uicontrol(thrRngBG,'Style','edit','String','',...
    'Tag','f2_hEdit','Position',[330 10 80 25],...
    'Enable','off');

% edit button strings
if ~isnan(thrVals(1)), f1_lEdit.String = sprintf('%.2f',thrVals(1)); end
if ~isnan(thrVals(2)), f1_hEdit.String = sprintf('%.2f',thrVals(2)); end
if ~isnan(thrVals(3)), f2_lEdit.String = sprintf('%.2f',thrVals(3)); end
if ~isnan(thrVals(4)), f2_hEdit.String = sprintf('%.2f',thrVals(4)); end

%--------------
% axis and plot

% calculate XLim (shows 95% of data unless thrVal is lower/higher)
thrXLim = [min([thrVals; descr.ptile95(1)]), max([thrVals; descr.ptile95(2)])];

% calculate xtick and xtick labels
thrXTick = linspace(thrXLim(1),thrXLim(2),6)';
thrXTickLab = num2str(thrXTick,'%.2f');

% create main axis
thrAx = axes(threshPan,'Tag','thrAx','Box','on','FontSize',10,...
    'Units','Pixels','Position',[50,30,455,145],...
    'XLim',[thrXLim(1)-0.1,thrXLim(2)+0.1],'XTick',thrXTick,'XTickLabel',thrXTickLab,...
    'YLim',[-0.1,1.1],'YTick',[0,0.5,1],'TickLength',[0,0],'YTickLabel',{'0','.5','1'},...
    'NextPlot','add','HitTest','off');

% set ylabel
ylabel(thrAx,'Opacity','FontSize',10);

% get vals for plot
thrX = linspace(thrXLim(1),thrXLim(2),1e5)';
thrY = cfgData_createThrMask(thrX,thrCode,thrVals);

% plot line
thrPlot = line(thrAx,'XData',thrX,'YData',thrY,'LineWidth',1,'Tag','thrPlot');

% create lines for filter values
thrFilt_a1 = line(thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_a1');
thrFilt_a2 = line(thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_a2');
thrFilt_b1 = line(thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_b1');
thrFilt_b2 = line(thrAx,'XData',[],'YData',[],'LineStyle','-.',...
    'Color',thrTxtCol(1,:),'Tag','thrFilt_b2');

% set filter line data
if ~isnan(thrVals(1)), set(thrFilt_a1,'XData',[thrVals(1),thrVals(1)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(2)), set(thrFilt_a2,'XData',[thrVals(2),thrVals(2)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(3)), set(thrFilt_b1,'XData',[thrVals(3),thrVals(3)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(4)), set(thrFilt_b2,'XData',[thrVals(4),thrVals(4)],'YData',[-0.05,1.05]); end

%  ========================================================================
%  ---------------------- OKAY/CANCEL/PREVIEW -----------------------------

% done button
doneBut = uicontrol(confDataFig,'Style','pushbutton','String','Done',...
    'Tag','doneBut','Position',[925,605,120,30],'BackgroundColor',...
    [46,204,113]/255,'Callback','');

% cancel button
cancBut = uicontrol(confDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[925,565,120,30],...
    'BackgroundColor',[231,76,60]/255,'Callback','');

% preview button
prevBut = uicontrol(confDataFig,'Style','pushbutton','String','Preview',...
    'Tag','prevBut','Position',[925,505,120,30],...
    'Callback','');






