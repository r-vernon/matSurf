function cBack_misc_saveHandles(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% open up save dialogue with default details
tmpFig = UI_saveData(handles,'handles',[],1,1);

% wait until finished saving
uiwait(tmpFig);

end