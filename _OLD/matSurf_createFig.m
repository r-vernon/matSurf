function [figHandle,handles] = matSurf_createFig(showFig)

if nargin <1 || isempty(showFig)
    showFig = true;
end

% =========================================================================
% set dimensions and spacings

% set size properties
f_Sz = [960,800,20]; % figure width, height, border
p_Sz = [140,160,20]; % panel width, height, v. spacing
b_Sz = [120,24,8]; % button width, height, v. spacing
a_Sz = f_Sz(2)-(2*f_Sz(3)); % axis width/height

% calculate panels (except axis panel) current position width and height
p_cW = f_Sz(3) + a_Sz; % fig border plus main axis width
p_cW = p_cW + (f_Sz(1) - p_cW - p_Sz(1))/2; % above width plus half remaining space
p_cH = f_Sz(2) - f_Sz(3) - p_Sz(2); % top of fig, minus fig border, minus panel height

% calculate buttons current position width and height
b_cW = (p_Sz(1)-b_Sz(1))/2; % half panel width minus button width
b_cH = p_Sz(2) - b_Sz(2) - (3*b_Sz(3)); % panel height minus button height minus 3x button spacing

% =========================================================================


% =========================================================================
% create main figure

% create a figure, hidden for now while being constructed
handles.matSurfFig = figure('Name','matSurf','Tag','matSurfFig','NumberTitle','off',...
    'FileName','matSurf.fig','Position',[100, 100, f_Sz(1), f_Sz(2)],...
    'Visible','off','MenuBar','none','DockControls','off');
figHandle = handles.matSurfFig;

% =========================================================================


% =========================================================================
% define panel defaults - come in a 'name', 'value' pair

panelDef.name = {'TitlePosition','FontSize','Units'};
panelDef.value = {'centertop',11,'pixels'};

% =========================================================================


% =========================================================================
% create the panels that will contain/border buttons etc

% axis panel
handles.axisPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.axisPanel,'Tag','axisPanel',...
    'Position',[f_Sz(3)-2, f_Sz(3)-2, a_Sz+4, a_Sz+4]);

% surface panel
handles.surfPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.surfPanel,'Tag','surfPanel','Title','Surface',...
    'Position',[p_cW, p_cH, p_Sz(1), p_Sz(2)]);
p_cH = p_cH - p_Sz(2) - p_Sz(3);

% data panel
handles.dataPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.dataPanel,'Tag','dataPanel','Title','Data',...
    'Position',[p_cW, p_cH, p_Sz(1), p_Sz(2)]);
p_cH = p_cH - p_Sz(2) - p_Sz(3);

% ROI panel
handles.roiPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.roiPanel,'Tag','roiPanel','Title','ROI',...
    'Position',[p_cW, p_cH, p_Sz(1), p_Sz(2)]);
p_cH = p_cH - p_Sz(2) - p_Sz(3);

% camera panel
handles.camPanel = uipanel(figHandle,panelDef.name,panelDef.value);
set(handles.camPanel,'Tag','camPanel','Title','Camera',...
    'Position',[p_cW, p_cH, p_Sz(1), p_Sz(2)]);

% =========================================================================


% =========================================================================
% create main axis (where data will be plotted)

% Data and PlotBox AspectRatioMode stops axis reshaping when moving camera
% Setting [XYZ]Color and Color to 'none' means the axis won't be visible
% Setting NextPlot to 'add' is like 'hold on'

handles.brainAx = axes(handles.axisPanel,'Tag','brainAx','Units','Pixels',...
    'Position',[4, 4, a_Sz-8, a_Sz-8],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XColor','none','YColor','none','ZColor','none','Color','none',...
    'NextPlot','add');

% create corresponding patch with default properties for now
handles.brainPatch = patch(handles.brainAx,'facecolor', 'interp',...
    'edgecolor','none','FaceLighting','gouraud','visible','off');
        
% =========================================================================


% =========================================================================
% create surface buttons

% make copy of current height so can be updated
tmp_h = b_cH;

% load surface button
handles.lSurf = uicontrol(handles.surfPanel,'Style','pushbutton','String','Load Surface',...
    'Tag','lSurf','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% lighting
handles.sLight = uicontrol(handles.surfPanel,'Style','pushbutton','String','Lighting',...
    'Tag','sLight','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);

% =========================================================================


% =========================================================================
% create data buttons

% make copy of current height so can be updated
tmp_h = b_cH;

% load data button
handles.lData = uicontrol(handles.dataPanel,'Style','pushbutton','String','Load Data',...
    'Tag','lData','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% select data menu
handles.sData = uicontrol(handles.dataPanel,'Style','popupmenu','String','Select Data',...
    'Tag','sData','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% config data button
handles.cData = uicontrol(handles.dataPanel,'Style','pushbutton','String','Config Data',...
    'Tag','cData','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% display data toggle
handles.dData = uicontrol(handles.dataPanel,'Style','checkbox','String','Show Data',...
    'Value',1,'Tag','dData','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);

% =========================================================================


% =========================================================================
% create ROI buttons

% make copy of current height so can be updated
tmp_h = b_cH;

% create ROI button
handles.cROI = uicontrol(handles.roiPanel,'Style','pushbutton','String','Create ROI',...
    'Tag','cROI','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% save ROI button
handles.sROI = uicontrol(handles.roiPanel,'Style','pushbutton','String','Save ROI(s)',...
    'Tag','sROI','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% remove ROI button
handles.rROI = uicontrol(handles.roiPanel,'Style','pushbutton','String','Remove ROI(s)',...
    'Tag','rROI','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% display ROIs toggle
handles.dROI = uicontrol(handles.roiPanel,'Style','checkbox','String','Show ROI(s)',...
    'Value',1,'Tag','dROI','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);

% =========================================================================


% =========================================================================
% create camera buttons

% make copy of current height so can be updated
tmp_h = b_cH;

% rotate camera button
handles.rCam = uicontrol(handles.camPanel,'Style','radiobutton','String','Rotate',...
    'Tag','rCam','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% translate camera button
handles.tCam = uicontrol(handles.camPanel,'Style','radiobutton','String','Translate',...
    'Tag','tCam','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);
tmp_h = tmp_h - b_Sz(2) - b_Sz(3);

% zoom camera button
handles.zCam = uicontrol(handles.camPanel,'Style','radiobutton','String','Zoom',...
    'Tag','zCam','Position',[b_cW,tmp_h,b_Sz(1),b_Sz(2)]);

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