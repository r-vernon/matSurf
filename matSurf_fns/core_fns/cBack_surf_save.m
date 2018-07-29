function cBack_surf_save(src,~)

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% open up save dialogue with default details
[saveMode,saveName,varToSave] = UI_saveData(currVol.surfDet.surfName,2,0,1);

% save the data (if didn't cancel)
if ~isempty(saveMode)
    if saveMode == 1 % if saving as file, use saveInstance method
        saveData(currVol.saveInstance,saveMode,saveName,varToSave,0)
    else
        saveData(currVol,saveMode,saveName,varToSave,0)
    end
    
    drawnow; pause(0.05);
end

end