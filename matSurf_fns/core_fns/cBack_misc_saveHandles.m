function cBack_misc_saveHandles(src,~)

% get data
f_h = getFigHandle(src);
handles = getappdata(f_h,'handles');

% open up save dialogue with default details
[fileOrVar,dataLoc] = UI_saveData('handles',[],2,1);

% save the data (if didn't cancel)
if ~isempty(fileOrVar)
    saveData(handles,fileOrVar,dataLoc,'handles',0)
    
    drawnow; pause(0.05);
end

end