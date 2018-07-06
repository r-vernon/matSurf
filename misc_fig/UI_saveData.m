function UI_saveData(data,defName)
% function to allow saving data, either in .mat file or in workspace

% if nargin < 2
%     defName = inputname(1);
% end

% keep track of saving in folder (true), or workspace (false)
saveFolder = true; 

% set default guide text
dir_gTxt = 'Enter path (hit return to continue)';
ws_gTxt = 'Enter variable name (hit return to continue)';

% set default warning text
dir_wTxt = 'Invalid path';
ws_wTxt = 'Invalid variable name';

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
saveDataFig = figure('Name','Save Data','Tag','saveDataFig','NumberTitle','off',...
    'FileName','saveData.fig','Units','pixels','Position',[100, 100, 460, 115],...
    'Visible','off','MenuBar','none','DockControls','off','Resize','off');

%  ========================================================================
%  ---------------------- SAVE IN DIR/WS ----------------------------------

% main panel
savePanel = uibuttongroup(saveDataFig,'Tag','savePanel','Title','Save in',...
    'Units','pixels','Position',[15,15,110,90]);

% save in folder
uicontrol(savePanel,'Style','radiobutton','String','Folder',...
    'Tag','saveDir','Position',[8 40 90 24]);

% save in workspace
uicontrol(savePanel,'Style','radiobutton','String','Workspace',...
    'Tag','saveWs','Position',[8 10 90 24]);

%  ========================================================================
%  ---------------------- SAVE LOCATION -----------------------------------

% text entry
uicontrol(saveDataFig,'Style','edit','Tag','nameTxt',...
    'HorizontalAlignment','left','Position',[135,70,285,25]);

% browse for folder
uicontrol(saveDataFig,'Style','pushbutton','String','...','Tag','browseBut',...
    'Position',[425,70,25,25]);

% guide text
uicontrol(saveDataFig,'Style','text','String',dir_gTxt,'Tag','guideTxt',...
    'HorizontalAlignment','left','FontSize',8,'Position',[135,50,285,15]);

% warning text
uicontrol(saveDataFig,'Style','text','String',dir_wTxt,'Tag','warnTxt',...
    'HorizontalAlignment','left','FontSize',8,'ForegroundColor','red',...
    'Position',[135,30,140,15],'Visible','off');

%  ========================================================================
%  ---------------------- SAVE/CANCEL BUTTONS -----------------------------

% save button (disabled until valid path/variable name provided)
uicontrol(saveDataFig,'Style','pushbutton','String','Save','Tag','saveBut',...
    'Position',[370,15,80,25],'BackgroundColor',[120,185,85]/255,...
    'Enable','off');

% cancel button
uicontrol(saveDataFig,'Style','pushbutton','String','Cancel','Tag','cancBut',...
    'Position',[280,15,80,25],'BackgroundColor',[250,110,105]/255);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.A
movegui(saveDataFig,'center');

% make visible
set(saveDataFig,'Visible','on');



% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

end