

% get inner size of panel (in pixels)
oldUnits = handles.axisPanel.Units;
handles.axisPanel.Units = 'pixels';
currSize = [1,1,handles.axisPanel.InnerPosition(3:4)];
handles.axisPanel.Units = oldUnits;

% by default print will include uipanels, so make new temp figure to print
% from, keeping as much the same as possible
scrSh_f = figure('Name','scrSh','Tag','scrSh_f','NumberTitle','off',...
    'FileName','scrSh.fig','Units','pixels','Position',currSize,...
    'Visible','on','MenuBar','none','DockControls','off','color','k');

% copy over axis
copyobj(handles.brainAx,scrSh_f);

% get new figure handles
newHandles = guihandles(scrSh_f);

% delete the marker
delete(newHandles.markPatch);

% set axis background color to none
newHandles.brainAx.Color = 'none';

% % save screenshot
print(scrSh_f,'./test.png','-dpng','-opengl');
% 
% % delete figure
delete(scrSh_f);

