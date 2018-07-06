function [figHandle,handles] = matSurf_createFig(showFig)

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

%% ========================================================================

%  ---------------------- DEFINING MENUBAR --------------------------------

%  ========================================================================
% create a menubar to allow additional options under each option

% new versions of Matlab use 'Text', older use 'Label', set accordingly
if isprop(uimenu,'Text'),Text = 'Text'; else, Text = 'Label'; end

handles.surfMenu = uimenu(figHandle,Text,'&Surface','Tag','surfMenu');
handles.dataMenu = uimenu(figHandle,Text,'&Data','Tag','dataMenu');
handles.roiMenu = uimenu(figHandle,Text,'&ROI','Tag','roiMenu');
handles.camMenu = uimenu(figHandle,Text,'&Camera','Tag','camMenu');

%% ========================================================================

%  ---------------------- SURFACE MENU ------------------------------------

%  ========================================================================
% menu items for surface

% set lighting properties
handles.setLight = uimenu(handles.surfMenu,Text,'Set Lighting',...
    'Tag','setLight');

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

% surface panel
nVItems.surf = 2;
panHeight = calcHeight(nVItems.surf);
panBottom = figSize.h - panSp - panHeight;
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

% Mode panel
nVItems.mode = 3; 
panHeight = calcHeight(nVItems.mode);
panBottom = panBottom - panSp - panHeight;
panPos.mode = [panLeft,panBottom,panWidth,panHeight];

% axis panel 
% - different spacings to rest, 2 padding around axis so axis fits inside
panPos.axis = [panSp-2, panSp-2, axLength+4, axLength+4];

%% ========================================================================

%  ---------------------- CREATE PANELS -----------------------------------

%  ========================================================================
% create the panels that will contain/border buttons etc

% axis panel
handles.axisPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.axisPanel,'Tag','axisPanel','Position',panPos.axis);

% surface panel
handles.surfPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.surfPanel,'Tag','surfPanel','Title','Surface',...
    'Position',panPos.surf);

% data panel
handles.dataPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.dataPanel,'Tag','dataPanel','Title','Data',...
    'Position',panPos.data);

% ROI panel
handles.roiPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.roiPanel,'Tag','roiPanel','Title','ROI',...
    'Position',panPos.ROI);

% camera panel
handles.camPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.camPanel,'Tag','camPanel','Title','Camera',...
    'Position',panPos.cam);

% mode panel
handles.modePanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.modePanel,'Tag','modePanel','Title','Mode',...
    'Position',panPos.mode);

%% ========================================================================

%  ---------------------- DEFINING AXIS -----------------------------------

%  ========================================================================
% create main axis (where data will be plotted)

% Data and PlotBox AspectRatioMode stops axis reshaping when moving camera
% Setting [XYZ]Color and Color to 'none' means the axis won't be visible
% Setting NextPlot to 'add' is like 'hold on'

handles.brainAx = axes(handles.axisPanel,'Tag','brainAx','Units','Pixels',...
    'Position',[4, 4, axLength-8, axLength-8],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XColor','none','YColor','none','ZColor','none','Color','none',...
    'NextPlot','add');

% create corresponding patch with default properties for now
handles.brainPatch = patch(handles.brainAx,'facecolor', 'interp',...
    'edgecolor','none','FaceLighting','gouraud','visible','off');

% create corresponding line for ROI plots -  'PickableParts' particularly
% important, setting to 'none' means can't be clicked
handles.brainROI = line(handles.brainAx,'Color','black','MarkerFaceColor','black',...
    'Marker','o','MarkerSize',3,'PickableParts','none',...
    'LineStyle','-','LineWidth',1.5,'visible','off');

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

%  ---------------------- FINAL PROPERTIES --------------------------------

%  ========================================================================
% finish up

% grab all handles
allHandles = fieldnames(handles);

% set all units to 'normalized' to allow resizing
for currHandle = 1:length(allHandles)
    try
        set(handles.(allHandles{currHandle}),'Units','normalized');
    catch
        % handle doesn't have units property so can't set
    end
end

% Move the window to the center of the screen.
movegui(handles.matSurfFig,'center')

% Make the UI visible.
if showFig
    set(handles.matSurfFig,'Visible','on');
end

end