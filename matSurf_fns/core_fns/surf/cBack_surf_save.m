function cBack_surf_save(src,~)

% get current volume
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 

% open up save dialogue with default details
saveName = currVol.surfDet.surfName;
[fileOrVar,dataLoc] = UI_saveData(saveName,2,0,1);

% save the data (if didn't cancel)
if ~isempty(fileOrVar)
    if fileOrVar == 1 % if saving as file, use saveInstance method
        saveData(currVol.saveInstance,fileOrVar,dataLoc,saveName,0)
    else
        saveData(currVol,fileOrVar,dataLoc,saveName,0)
    end
    
    drawnow; pause(0.05);
end

end