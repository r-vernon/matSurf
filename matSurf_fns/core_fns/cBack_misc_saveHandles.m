function cBack_misc_saveHandles(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% open up save dialogue with default details
UI_saveData(handles,'handles',[],1,1);
drawnow; pause(0.05);

end