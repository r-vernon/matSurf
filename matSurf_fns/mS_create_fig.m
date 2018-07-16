function [figHandle,handles] = mS_create_fig(showFig)

if nargin <1 || isempty(showFig)
    showFig = true;
end

%% ========================================================================

%  ---------------------- DEFAULT SPACINGS --------------------------------

%  ========================================================================
% set starting dimensions and spacings (all in pixels, made relative later)

 % figure height, width
figSize = struct('h',800,'w',960);

% default spacing around panels
panSp = 20; 

% button height and spacing ratio for buttons
butHeight = 24; 
butSp = 1/3 * butHeight; % set to 1/3 uicontrol height

 % axis length - fig. size minus 2x default panel spacing (for top,bottom)
axLength = figSize.h - 2*panSp;

%% ========================================================================

%  ---------------------- DEFINING FIGURE ---------------------------------

%  ========================================================================
% create main figure

% create a figure, hidden for now while being constructed
handles.matSurfFig = figure('Name','matSurf','Tag','matSurfFig','NumberTitle','off',...
    'FileName','matSurf.fig','Position',[100, 100, figSize.w, figSize.h],...
    'Visible','off','MenuBar','none','DockControls','off');
figHandle = handles.matSurfFig;

% create a status text entry in lower left corner
handles.statTxt = uicontrol(figHandle,'Style','text','Tag','statTxt',...
    'String','- no data loaded -','HorizontalAlignment','right',...
    'FontSize',8,'FontAngle','italic','ForegroundColor',[0.35,0.35,0.35],...
    'Position',[axLength+panSp-300,1,300,15]);

%% ========================================================================

%  ---------------------- DEFINING MENUBAR --------------------------------

%  ========================================================================
% create a menubar to allow additional options under each option

% new versions of Matlab use 'Text', older use 'Label', set accordingly
tmpMenu = uimenu;
if isprop(tmpMenu,'Text'),Text = 'Text'; else, Text = 'Label'; end
delete(tmpMenu);

handles.surfMenu  = uimenu(figHandle,Text,'&Surface', 'Tag', 'surfMenu');
handles.dataMenu  = uimenu(figHandle,Text,'&Data',    'Tag', 'dataMenu');
handles.roiMenu   = uimenu(figHandle,Text,'&ROI',     'Tag', 'roiMenu');
handles.camMenu   = uimenu(figHandle,Text,'&Camera',  'Tag', 'camMenu');
handles.miscMenu  = uimenu(figHandle,Text,'&Misc',    'Tag', 'miscMenu');
handles.udateMenu = uimenu(figHandle,Text,'&Update',  'Tag', 'udateMenu');

%% ========================================================================

%  ---------------------- SURFACE MENU ------------------------------------

%  ========================================================================
% menu items for surface

% save surface
handles.saveSurf = uimenu(handles.surfMenu,Text,'Save Surface',...
    'Tag','saveSurf');

% set lighting properties
handles.setLight = uimenu(handles.surfMenu,Text,'Set Lighting',...
    'Tag','setLight');

%% ========================================================================

%  ---------------------- ROI MENU ----------------------------------------

%  ========================================================================
% menu items for ROIs

% finish ROI
handles.finROI = uimenu(handles.roiMenu,Text,'Finish ROI',...
    'Tag','finROI');

%% ========================================================================

%  ---------------------- MISC MENU ---------------------------------------

%  ========================================================================
% misc. menu items

% save handles
handles.saveHndls = uimenu(handles.miscMenu,Text,'Save Graphics Handles',...
    'Tag','saveHndls');

%% ========================================================================

%  ---------------------- DEFINE PANEL DEFAULTS ---------------------------

%  ========================================================================
% define panel defaults - come in a 'name', 'value' pair

panelDef.name = {'TitlePosition','FontSize','Units'};
panelDef.value = {'centertop',11,'pixels'};

% calculate dimensions and spacings for each panel
% > panWidth/panHeight - width and height of panel
% > panLeft/panBottom - distance from left/bottom edge of parent
% > nVItems - number of 'vertical' items

% set defaults
panWidth = figSize.w - axLength - 3*panSp; % 3*defSp for left,right of panel, and left of axis
panLeft = axLength + 2*panSp;

% set height calculator
calcHeight = @(nVItems) (nVItems*butHeight) + (nVItems*butSp) + panSp;

% Mode panel
nVItems.mode = 3; 
panHeight = calcHeight(nVItems.mode);
panBottom = figSize.h - panSp - panHeight;
panPos.mode = [panLeft,panBottom,panWidth,panHeight];

% surface panel
nVItems.surf = 2;
panHeight = calcHeight(nVItems.surf);
panBottom = panBottom - panSp - panHeight;
panPos.surf = [panLeft,panBottom,panWidth,panHeight];

% data panel
nVItems.data = 5; 
panHeight = calcHeight(nVItems.data);
panBottom = panBottom - panSp - panHeight;
panPos.data = [panLeft,panBottom,panWidth,panHeight];

% ROI panel
nVItems.ROI = 5; 
panHeight = calcHeight(nVItems.ROI);
panBottom = panBottom - panSp - panHeight;
panPos.ROI = [panLeft,panBottom,panWidth,panHeight];

% Cam panel
nVItems.cam = 3; 
panHeight = calcHeight(nVItems.cam);
panBottom = panBottom - panSp - panHeight;
panPos.cam = [panLeft,panBottom,panWidth,panHeight];

% axis panel 
% - different spacings to rest, 2 padding around axis so axis fits inside
panPos.axis = [panSp-2, panSp-2, axLength+4, axLength+4];

%% ========================================================================

%  ---------------------- CREATE PANELS -----------------------------------

%  ========================================================================
% create the panels that will contain/border buttons etc

% axis panel
handles.axisPanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.axisPanel.Tag = 'axisPanel';
handles.axisPanel.Position = panPos.axis;

% surface panel
handles.surfPanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.surfPanel.Tag = 'surfPanel';
handles.surfPanel.Title = 'Surface';
handles.surfPanel.Position = panPos.surf;

% data panel
handles.dataPanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.dataPanel.Tag = 'dataPanel';
handles.dataPanel.Title = 'Data';
handles.dataPanel.Position = panPos.data;

% ROI panel
handles.roiPanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.roiPanel.Tag = 'roiPanel';
handles.roiPanel.Title = 'ROI';
handles.roiPanel.Position = panPos.ROI;

% camera panel
handles.camPanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.camPanel.Tag = 'camPanel';
handles.camPanel.Title = 'Camera';
handles.camPanel.Position = panPos.cam;

% mode panel
handles.modePanel = uipanel(figHandle,panelDef.name,panelDef.value);
handles.modePanel.Tag = 'modePanel';
handles.modePanel.Title = 'Mode';
handles.modePanel.Position = panPos.mode;

%% ========================================================================

%  ---------------------- DEFINING AXIS -----------------------------------

%  ========================================================================
% create main axis (where data will be plotted)

% Data and PlotBox AspectRatioMode stops axis reshaping when moving camera
% Setting [XYZ]Color and Color to 'none' means the axis won't be visible
% Setting all camera modes to manual for custom control
% Setting NextPlot to 'add' is like 'hold on'

handles.brainAx = axes(handles.axisPanel,'Tag','brainAx',...
    'Units','Pixels','Position',[4, 4, axLength-8, axLength-8],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
    'XColor','none','YColor','none','ZColor','none','Color','none',...
    'CameraPositionMode','manual','CameraTargetMode','manual',...
    'CameraUpVectorMode','manual','CameraViewAngleMode','manual',...
    'NextPlot','add');

% create transform object so can rotate patch
handles.xForm = hgtransform('Parent',handles.brainAx,'Tag','xForm');

% create corresponding patch with default properties for now
handles.brainPatch = patch(handles.brainAx,'Parent',handles.xForm ,...
    'facecolor', 'interp','edgecolor','none','MarkerEdgeColor','none',...
    'FaceLighting','gouraud','visible','off');

% create corresponding line for ROI plots -  'PickableParts' particularly
% important, setting to 'none' means can't be clicked
% [NOTE: limitation of line is all ROIs are same colour, possibly switch to
%  making patch object if want different coloured ROIs at cost of memory]
handles.brainROI = line(handles.brainAx,'Parent',handles.xForm ,...
    'Color','black','MarkerFaceColor','black',...
    'Marker','o','MarkerSize',3,'PickableParts','none',...
    'LineStyle','-','LineWidth',3,'visible','off');

%% ========================================================================

%  ---------------------- BUTTON DEFAULTS ---------------------------------

%  ========================================================================
% calculate dimensions and spacings for each button

% set properties for full button
f_Sz = 0.8; % 1x full button will be 80% of panel
f_butWidth = f_Sz * panWidth;  
f_LPos = (1 - f_Sz)/2 * panWidth;

% set properties for half button
% will have normal spacings to left/right, but half normal in middle
h_butWidth = (panWidth - 2.5*f_LPos)/2;  
h_LPos1 = f_LPos;
h_LPos2 = f_LPos + h_butWidth + f_LPos/2;

%% ========================================================================

%  ---------------------- MODE BUTTONS ------------------------------------

%  ========================================================================
% mode buttons

% set current height
currH = (nVItems.mode * butSp) + ((nVItems.mode-1) * butHeight);

% Camera mode button
handles.camMode = uicontrol(handles.modePanel,'Style','radiobutton',...
    'String','Camera Mode','Tag','camMode',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]); 

% update current height
currH = currH - (butHeight + butSp);  

%  Data mode button
handles.dataMode = uicontrol(handles.modePanel,'Style','radiobutton',...
    'String','Data Mode','Tag','dataMode','Value',1,...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% ROI mode button
handles.roiMode = uicontrol(handles.modePanel,'Style','radiobutton',...
    'String','ROI Mode','Tag','roiMode',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

%% ========================================================================

%  ---------------------- SURFACE BUTTONS ---------------------------------

%  ========================================================================
% create surface buttons

% set current height
currH = (nVItems.surf * butSp) + ((nVItems.surf-1) * butHeight);

% add surface button
handles.addSurf = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Add','Tag','addSurf',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight]);

% delete surface button
handles.delSurf = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Del.','Tag','delSurf',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% select surface menu
handles.selSurf = uicontrol(handles.surfPanel,'Style','popupmenu',...
    'String','Select Surface','Tag','selSurf',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

%% ========================================================================

%  ---------------------- DATA BUTTONS ------------------------------------

%  ========================================================================
% create data buttons

% set current height
currH = (nVItems.data * butSp) + ((nVItems.data-1) * butHeight);

% add data button
handles.addData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Add','Tag','addData',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight]);

% delete data button
handles.delData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Del.','Tag','delData',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp); 

% select data menu
handles.selData = uicontrol(handles.dataPanel,'Style','popupmenu',...
    'String','Select Data','Tag','selData',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% config data button
handles.cfgData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Config. Data','Tag','cfgData',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% save data button
handles.savData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Save Data','Tag','savData',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% show data toggle
handles.togData = uicontrol(handles.dataPanel,'Style','checkbox',...
    'String','Show Data','Tag','togData','Value',1,...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

%% ========================================================================

%  ---------------------- ROI BUTTONS -------------------------------------

%  ========================================================================
% create ROI buttons

% set current height
currH = (nVItems.ROI * butSp) + ((nVItems.ROI-1) * butHeight);

% add ROI button
handles.addROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Add','Tag','addROI',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight]);

% delete ROI button
handles.delROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Del.','Tag','delROI',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% select ROI menu
handles.selROI = uicontrol(handles.roiPanel,'Style','popupmenu',...
    'String','Select ROI','Tag','selROI',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% config ROI button
handles.cfgROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Config. ROI(s)','Tag','cfgROI',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% save ROI button
handles.savROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Save ROI(s)','Tag','savROI',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% show ROIs toggle
handles.togROI = uicontrol(handles.roiPanel,'Style','checkbox',...
    'String','Show ROI(s)','Tag','togROI','Value',1,...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

%% ========================================================================

%  ---------------------- CAMERA BUTTONS ----------------------------------

%  ========================================================================

% create camera buttons

% set current height
currH = (nVItems.cam * butSp) + ((nVItems.cam-1) * butHeight);

% rotate camera button
handles.rotCam = uicontrol(handles.camPanel,'Style','radiobutton',...
    'String','Rot.','Tag','rotCam',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight]); 

% pan camera button
handles.panCam = uicontrol(handles.camPanel,'Style','radiobutton',...
    'String','Pan','Tag','panCam',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% zoom camera button
handles.zoomCam = uicontrol(handles.camPanel,'Style','radiobutton',...
    'String','Zoom','Tag','zoomCam',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% reset camera button
handles.resCam = uicontrol(handles.camPanel,'Style','pushbutton',...
    'String','Reset Camera','Tag','resCam',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

%% ========================================================================

%  ---------------------- POINTER MANAGER ---------------------------------

%  ========================================================================

% find handles want to show 'hand' over (popupmenus don't work...)
clickObj = findall(figHandle,'Style','radiobutton','-or',...
    'Style','checkbox','-or','Style','pushbutton');

% whenever text hovers over button, change to hand
enterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior(clickObj, enterFcn);

% create a pointer manager
iptPointerManager(figHandle);

%% ========================================================================

%  ---------------------- FINAL PROPERTIES --------------------------------

%  ========================================================================
% finish up

% grab all handles
allHandles = fieldnames(handles);

% set all units to 'normalized' to allow resizing
for currHandle = 1:length(allHandles)
    try
        handles.(allHandles{currHandle}).Units = 'normalized';
    catch
        % handle doesn't have units property so can't set
    end
end

% assign handles to app data
setappdata(figHandle,'handles',handles);

% Move the window to the center of the screen.
movegui(handles.matSurfFig,'center');

% Make the UI visible.
if showFig
    handles.matSurfFig.Visible = 'on';
end

end