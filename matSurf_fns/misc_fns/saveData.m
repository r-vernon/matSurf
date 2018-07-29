function saveData(data,saveMode,saveName,varToSave,appndData)
% function to save data, either as file or variable
% assumes inputs from UI_saveData, so does not do any validation!
%
% (req.) data, data to save
% (req.) saveMode, 1 for saving as file, 2 for saving as variable
% (req.) saveName, file or variable name for saving
% (req.) varToSave, the name of the variable that will be saved
% (opt.) appendData, if true and saving as file, appends to file

% check if appending data
% need isempty before ~= 0, 1 as get operator...convertible error otherwise
if saveMode == 2 || nargin < 5 || isempty(appndData) || (appndData ~= 0 && appndData ~= 1)
    
    appndData = false;
    
end

if saveMode == 1 % saving as file
    
    if appndData
        save(saveName,'data','-mat','-append');
        prStr = sprintf('Appended %s to %s',varToSave,saveName);
    else
        save(saveName,'data','-mat');
        prStr = sprintf('Saved %s to %s',varToSave,saveName);
    end
    
else % saving as variable
    
    assignin('base',saveName,data);
    prStr = sprintf('Assigned %s to workspace as %s',varToSave,saveName);
    
end

% set status text, and also show in workspace (the '1' input arg)
setStatusTxt(prStr,'',1);

end