function cBack_cam_screenshot(src,~)

% get data
f_h = getFigHandle(src);
camControl = getappdata(f_h,'camControl');
handles = getappdata(f_h,'handles');

%--------------------------------------------------------------------------
% get details of how to save the screenshot (resolution/format etc)

% get the current size of the axis in pixels
oldUnits = handles.axisPanel.Units;
handles.axisPanel.Units = 'pixels';
currSize = handles.axisPanel.InnerPosition(3:4);
handles.axisPanel.Units = oldUnits;

% append pixels/inch (ppi) of screen
currSize(3) = get(groot,'ScreenPixelsPerInch');

% pass to saveScreenshot UI
saveFmt = UI_saveScreenshot(currSize);

if isempty(saveFmt) % clicked cancel
    return
end

%--------------------------------------------------------------------------
% generate a potential name for screenshot

% get surface name
if ischar(handles.selSurf.String)
    surfName = handles.selSurf.String;
else
    surfName = handles.selSurf.String{handles.selSurf.Value};
end

% see if current view is one of any saved views
if ~isempty(camControl.view)
    surfName = [surfName,'_',camControl.view,'.',saveFmt.fmt];
else
    surfName = [surfName,'_scrShot.',saveFmt.fmt];
end

% get a valid filename
[file,path] = uiputfile( ...
    {['*.',saveFmt.fmt],[upper(saveFmt.fmt),'s (*.',saveFmt.fmt,')']; ...
    '*.bmp;*.gif;*.jpg;*.jpeg;*.png;*.tif;*.tiff', ...
    'Image files (*.bmp, *.gif, *.jpg, *.jpeg, *.png, *.tif, *.tiff)'; ...
    '*.*', 'All files (*.*)'}, 'Choose screenshot save location', surfName);

% construct filename
if isequal(file,0) || isequal(path,0) % clicked cancel
    return;
else
   saveFmt.filename = fullfile(path,file);
end

%--------------------------------------------------------------------------
% pass the details through to the image writing function

cam_screenshot(f_h,currSize,saveFmt);

setStatusTxt(handles.statTxt,sprintf('Saved %s in %s',file,path));

end
