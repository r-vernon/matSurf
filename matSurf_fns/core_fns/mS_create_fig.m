function [figHandle] = mS_create_fig(showFig)

if nargin <1 || isempty(showFig)
    showFig = true;
end

%% ========================================================================

%  ---------------------- DEFAULT SPACINGS --------------------------------

%  ========================================================================
% set starting dimensions and spacings (all in pixels, made relative later)

 % figure height, width
figSize = struct('h',790,'w',950);

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
% UserData will contain time stamp of last interaction
handles.matSurfFig = figure('Name','matSurf','Tag','matSurfFig','NumberTitle','off',...
    'FileName','matSurf.fig','Position',[100, 100, figSize.w, figSize.h],...
    'Visible','off','MenuBar','none','DockControls','off',...
    'Renderer','opengl','UserData',now);
figHandle = handles.matSurfFig;

% create a status text entry in lower left corner
handles.statTxt = uicontrol(figHandle,'Style','text','Tag','statTxt',...
    'String','- no data loaded -','HorizontalAlignment','right',...
    'FontSize',8,'FontAngle','italic','ForegroundColor',[0.35,0.35,0.35],...
    'Position',[axLength+panSp-axLength,1,axLength,15]);

% grab context menu for copy/paste
handles.cpMenu = copy_paste_menu;

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
    'Tag','saveSurf','Enable','off','Callback',@cBack_surf_save);

% set lighting properties
handles.setLight = uimenu(handles.surfMenu,Text,'Set Lighting',...
    'Tag','setLight');

%% ========================================================================

%  ---------------------- ROI MENU ----------------------------------------

%  ========================================================================
% menu items for ROIs

% undo last ROI point
handles.undoROI = uimenu(handles.roiMenu,Text,'Undo',...
    'Tag','undoROI','Enable','off','Callback',@cBack_ROI_undo);

% rename ROI
handles.renROI = uimenu(handles.roiMenu,Text,'Rename ROI',...
    'Tag','renROI','Enable','off','Callback',@cBack_ROI_rename);

% finish ROI
handles.finROI = uimenu(handles.roiMenu,Text,'Finish ROI',...
    'Tag','finROI','Enable','off','Callback',@cBack_ROI_addPnt);

% import ROI
handles.impROI = uimenu(handles.roiMenu,Text,'Import ROI(s)',...
    'Tag','impROI','Enable','off','Callback',@cBack_ROI_import);

% export ROI
handles.expROI = uimenu(handles.roiMenu,Text,'Export ROI(s)',...
    'Tag','expROI','Enable','off','Callback',@cBack_ROI_export);

%% ========================================================================

%  ---------------------- CAMERA MENU -------------------------------------

%  ========================================================================
% menu items for camera

% save screenshot
handles.saveScrShot = uimenu(handles.camMenu,Text,'Save Screenshot',...
    'Tag','saveScrShot','Enable','off','Callback',@cBack_cam_screenshot);

%% ========================================================================

%  ---------------------- MISC MENU ---------------------------------------

%  ========================================================================
% misc. menu items

% save handles
handles.saveHndls = uimenu(handles.miscMenu,Text,'Save Graphics Handles',...
    'Tag','saveHndls','Callback',@cBack_misc_saveHandles);

%% ========================================================================

%  ---------------------- DEFINE PANEL DEFAULTS ---------------------------

%  ========================================================================

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
nVItems.mode = 2; 
panHeight = calcHeight(nVItems.mode);
panBottom = figSize.h - panSp - panHeight;
panPos.mode = [panLeft,panBottom,panWidth,panHeight];

% surface panel
nVItems.surf = 5;
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

% axis panel 
% - different spacings to rest, 2 padding around axis so axis fits inside
panPos.axis = [panSp-2, panSp-2, axLength+4, axLength+4];

%% ========================================================================

%  ---------------------- CREATE PANELS -----------------------------------

%  ========================================================================
% create the panels that will contain/border buttons etc

% axis panel
handles.axisPanel = uipanel(figHandle,'Tag','axisPanel',...
    'Units','pixels','Position',panPos.axis);

% mode button group
handles.modePanel = uibuttongroup(figHandle,'Tag','modePanel',...
    'Title','Mode','Units','pixels','Position',panPos.mode);

% surface panel
handles.surfPanel = uipanel(figHandle,'Tag','surfPanel',...
    'Title','Surface','Units','pixels','Position',panPos.surf);

% data panel
handles.dataPanel = uipanel(figHandle,'Tag','dataPanel',...
    'Title','Data','Units','pixels','Position',panPos.data);

% ROI panel
handles.roiPanel = uipanel(figHandle,'Tag','roiPanel',...
    'Title','ROI','Units','pixels','Position',panPos.ROI);

% set defaults
set([handles.axisPanel, handles.modePanel, handles.surfPanel, ...
    handles.dataPanel, handles.roiPanel],...
    'TitlePosition','centertop','FontSize',11);

%% ========================================================================

%  ---------------------- DEFINING AXIS -----------------------------------

%  ========================================================================
% create main axis (where data will be plotted)

% Data and PlotBox AspectRatioMode stops axis reshaping when moving camera
% Setting [XYZ]Color and Color to 'none' means the axis won't be visible
% Setting all camera modes to manual for custom control
% Setting HitTest off, so mouse clicked passed to panel ancestor
% Setting NextPlot to 'add' is like 'hold on'

handles.brainAx = axes(handles.axisPanel,'Tag','brainAx',...
    'Units','Pixels','Position',[4, 4, axLength-8, axLength-8],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XLimMode','manual','YLimMode','manual','ZLimMode','manual',...
    'XColor','none','YColor','none','ZColor','none','Color','none',...
    'CameraPositionMode','manual','CameraTargetMode','manual',...
    'CameraUpVectorMode','manual','CameraViewAngleMode','manual',...
    'HitTest','off','NextPlot','add');

% create transform object so can rotate patch
handles.xForm = hgtransform('Parent',handles.brainAx,'Tag','xForm');

% create patch for surface with default properties for now
handles.brainPatch = patch(handles.xForm,'Tag','brainPatch',...
    'facecolor', 'interp','edgecolor','none','Marker','none',...
    'FaceLighting','gouraud','BackFaceLighting','lit',...
    'AmbientStrength',0.6,'DiffuseStrength',0.15,...
    'SpecularStrength',0.1,'SpecularExponent',25,...
    'visible','off');

% create patch for ROI plots
% (setting 'PickableParts' to 'none' means can't be clicked)
handles.brainROI = patch(handles.xForm,'Tag','brainROI',...
    'facecolor','none','edgecolor','black','Marker','none',...
    'LineWidth',2,... % put CData here
    'FaceLighting','none','EdgeLighting','none',...
    'visible','off','PickableParts','none');

% create patch for marker to indicate vertex clicked
handles.markPatch = patch(handles.xForm,'Tag','markPatch',...
    'faces',[],'vertices',[],'MarkerEdgeColor','none',...
    'facecolor','flat','edgecolor','none',...
    'FaceLighting','gouraud','BackFaceLighting','lit',...
    'AmbientStrength',0.6,'DiffuseStrength',0.2,...
    'SpecularStrength',0,'PickableParts','none');

% create lights
handles.llLight = light('Style','local','Tag','llLight',...
    'Color',[1,1,1],'Parent',handles.brainAx);
handles.lrLight = light('Style','local','Tag','lrLight',...
    'Color',[1,1,1],'Parent',handles.brainAx);
handles.ulLight = light('Style','local','Tag','ulLight',...
    'Color',[1,1,1],'Parent',handles.brainAx);
handles.urLight = light('Style','local','Tag','urLight',...
    'Color',[1,1,1],'Parent',handles.brainAx);

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

% set properties for 1/3, 2/3 button
% will have normal spacings to left/right, but half normal in middle
% second button will have width 2*t_butWidth
t_butWidth = (panWidth - 2.5*f_LPos)/3;  
t_LPos1 = f_LPos;
t_LPos2 = f_LPos + t_butWidth + f_LPos/2;

%% ========================================================================

%  ---------------------- MODE BUTTONS ------------------------------------

%  ========================================================================
% mode buttons

% set current height
currH = (nVItems.mode * butSp) + ((nVItems.mode-1) * butHeight);

%  Data mode button
handles.dataMode = uicontrol(handles.modePanel,'Style','radiobutton',...
    'String','Data Mode','Tag','dataMode','Value',1,...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% ROI mode button
handles.roiMode = uicontrol(handles.modePanel,'Style','radiobutton',...
    'String','ROI Mode','Tag','roiMode','Value',0,...
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
    'Position',[h_LPos1,currH,h_butWidth,butHeight],...
    'Callback',@cBack_surf_add);

% delete surface button
handles.delSurf = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Del.','Tag','delSurf','Enable','off',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% select surface menu
handles.selSurf = uicontrol(handles.surfPanel,'Style','popupmenu',...
    'String','Select Surface','Tag','selSurf','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_surf_select);

% update current height
currH = currH - (butHeight + butSp);  

% selected vertex text (reducing butHeight slightly for better alignment)
handles.svTxt = uicontrol(handles.surfPanel,'Style','text',...
    'String','Vert.','Tag','svTxt','Enable','off',...
    'Position',[t_LPos1,currH,t_butWidth,butHeight-4]);
    
% selected vertex edit
handles.svEdit = uicontrol(handles.surfPanel,'Style','edit',...
    'String','','Tag','svEdit','Enable','off',...
    'Position',[t_LPos2,currH,2*t_butWidth,butHeight],...
    'Callback',@cBack_surf_setVert);

% update current height
currH = currH - (butHeight + butSp);  

% show marker toggle
handles.togMark = uicontrol(handles.surfPanel,'Style','checkbox',...
    'String','Show Marker','Tag','togMark','Value',1,'Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_surf_toggleMarker);

% update current height
currH = currH - (butHeight + butSp);  

% reset camera button (in this panel just for convenience)
handles.resCam = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Reset Camera','Tag','resCam','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_cam_camReset);

%% ========================================================================

%  ---------------------- DATA BUTTONS ------------------------------------

%  ========================================================================
% create data buttons

% set current height
currH = (nVItems.data * butSp) + ((nVItems.data-1) * butHeight);

% add data button
handles.addData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Add','Tag','addData','Enable','off',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight],...
    'Callback',@cBack_data_add);

% delete data button
handles.delData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Del.','Tag','delData','Enable','off',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight],...
    'Callback',@cBack_data_delete);

% update current height
currH = currH - (butHeight + butSp); 

% select data menu
handles.selData = uicontrol(handles.dataPanel,'Style','popupmenu',...
    'String','Select Data','Tag','selData','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_data_select);

% update current height
currH = currH - (butHeight + butSp);  

% config data button
handles.cfgData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Config. Data','Tag','cfgData','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% save data button
handles.saveData = uicontrol(handles.dataPanel,'Style','pushbutton',...
    'String','Save Data','Tag','saveData','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% show data toggle
handles.togData = uicontrol(handles.dataPanel,'Style','checkbox',...
    'String','Show Data','Tag','togData','Value',1,'Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_data_toggle);

%% ========================================================================

%  ---------------------- ROI BUTTONS -------------------------------------

%  ========================================================================
% create ROI buttons

% set current height
currH = (nVItems.ROI * butSp) + ((nVItems.ROI-1) * butHeight);

% add ROI button
handles.addROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Add','Tag','addROI','Enable','off',...
    'Position',[h_LPos1,currH,h_butWidth,butHeight],...
    'Callback',@cBack_mode_set);

% delete ROI button
handles.delROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Del.','Tag','delROI','Enable','off',...
    'Position',[h_LPos2,currH,h_butWidth,butHeight],...
    'Callback',@cBack_ROI_delete);

% update current height
currH = currH - (butHeight + butSp);  

% select ROI menu
handles.selROI = uicontrol(handles.roiPanel,'Style','popupmenu',...
    'String','Select ROI','Tag','selROI','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_ROI_select);

% update current height
currH = currH - (butHeight + butSp);  

% config ROI button
handles.cfgROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Config. ROI','Tag','cfgROI','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);  

% save ROI button
handles.saveROI = uicontrol(handles.roiPanel,'Style','pushbutton',...
    'String','Save ROI','Tag','saveROI','Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_ROI_save);

% update current height
currH = currH - (butHeight + butSp);  

% show ROIs toggle
handles.togROI = uicontrol(handles.roiPanel,'Style','checkbox',...
    'String','Show ROIs','Tag','togROI','Value',1,'Enable','off',...
    'Position',[f_LPos,currH,f_butWidth,butHeight],...
    'Callback',@cBack_ROI_toggle);

%% ========================================================================

%  ---------------------- POINTER MANAGER ---------------------------------

%  ========================================================================

% find handles want to show 'hand' over (popupmenus don't work...)
clickObj = findall(figHandle,'Style','radiobutton','-or',...
    'Style','checkbox','-or','Style','pushbutton');

% whenever text hovers over button, change to hand
enterFcn = @(fig,~) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior(clickObj, enterFcn);

% whenever move over patch, set pointer to cross
enterFcn = @(fig,~) set(fig, 'Pointer', 'cross');
iptSetPointerBehavior(handles.brainPatch, enterFcn);

% create a pointer manager
iptPointerManager(figHandle);

%% ========================================================================

%  ---------------------- FINAL PROPERTIES --------------------------------

%  ========================================================================
% finish up

% grab all handles
allHandles = fieldnames(handles);

% set all units to 'normalized' to allow resizing and non-interruptible
for currHandle = 1:numel(allHandles)
    try handles.(allHandles{currHandle}).Units = 'normalized';
    catch % handle doesn't have units property so can't set
    end
    try handles.(allHandles{currHandle}).Interruptible = 'off';
    catch % handle doesn't have interruptible property so can't set
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