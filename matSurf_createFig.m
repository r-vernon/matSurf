function [figHandle,handles] = matSurf_createFig(showFig)

if nargin <1 || isempty(showFig)
    showFig = true;
end

% =========================================================================
% set dimensions and spacings

% set starting size properties
figSize = struct('h',800,'w',960); % figure height, width in pixels
panSp = 20; % default spacing around panels
butHeight = 24; % button height
butSp = 1/3 * butHeight; % spacing ratio for buttons, i.e. 1/3 uicontrol height
axLength = figSize.h - 2*panSp; % axis width/height, 2*defSp for top,bottom

% =========================================================================

%------------------------ DEFINING FIGURE ---------------------------------

% =========================================================================
% create main figure

% create a figure, hidden for now while being constructed
handles.matSurfFig = figure('Name','matSurf','Tag','matSurfFig','NumberTitle','off',...
    'FileName','matSurf.fig','Position',[100, 100, figSize.w, figSize.h],...
    'Visible','off','MenuBar','none','DockControls','off');
figHandle = handles.matSurfFig;

% =========================================================================

%------------------------ DEFINING PANELS----------------------------------

% =========================================================================
% define panel defaults - come in a 'name', 'value' pair

panelDef.name = {'TitlePosition','FontSize','Units'};
panelDef.value = {'centertop',11,'pixels'};

% =========================================================================


% =========================================================================
% calculate dimensions and spacings for each panel
%
% panWidth/panHeight - width and height of panel
% panLeft/panBottom - distance from left/bottom edge of parent
% nVItems - number of 'vertical' items

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

% axis panel 
% - different spacings to rest, 2 padding around axis so axis fits inside
panPos.axis = [panSp-2, panSp-2, axLength+4, axLength+4];

% =========================================================================


% =========================================================================
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

% =========================================================================

%------------------------ DEFINING AXIS -----------------------------------

% =========================================================================
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
        
% =========================================================================

%------------------------ DEFINING BUTTONS --------------------------------

% =========================================================================
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

% =========================================================================


% =========================================================================
% create surface buttons

% set current height
currH = (nVItems.surf * butSp) + ((nVItems.surf-1) * butHeight);

% add surface button
handles.addSurf = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Add Surface','Tag','addSurf',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% update current height
currH = currH - (butHeight + butSp);

% set lighting
handles.setLight = uicontrol(handles.surfPanel,'Style','pushbutton',...
    'String','Set Lighting','Tag','setLight',...
    'Position',[f_LPos,currH,f_butWidth,butHeight]);

% =========================================================================


% =========================================================================
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

% =========================================================================


% =========================================================================
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

% =========================================================================


% =========================================================================
% create camera buttons

% % calculate button and spacing height in normalised units
% % panel height saved in panPos.cam(4)
% butHeight = get_buttonHeight(panPos.cam(4));
% topHeight = get_topHeight(panPos.cam(4));
% spHeight = get_spacingHeight(butHeight, nVItems.cam, topHeight);

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

% =========================================================================


% =========================================================================
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