function saveData(data,fileOrVar,dataLoc,saveName,appndData)
% function to save data, either as file or variable
% assumes inputs from UI_saveData, so does not do much validation!
%
% (req.) data, data to save
% (req.) fileOrVar, 1 for saving as file, 2 for saving as variable
% (req.) dataLoc, location of file or variable name for saving
% (opt.) saveName, the name of the variable that will be saved
% (opt.) appendData, if true and saving as file, appends to file

% check if varToSave is valid
if nargin < 4 || ~isvarname(saveName)
    if isvarname(dataLoc), saveName = dataLoc;
    else
        [~,saveName,~] = fileparts(dataLoc);
        if ~isvarname(saveName)
            saveName = 'data';
        end
    end
end 

% check if appending data
% need isempty before ~= 0, 1 as get operator...convertible error otherwise
if fileOrVar == 2 || nargin < 5 || isempty(appndData) || (appndData ~= 0 && appndData ~= 1) 
    appndData = false; 
end

if fileOrVar == 1 % saving as file
    
    % create struct whos fieldname is 'varToSave'
    s.(saveName) = data;
    
    if appndData
        save(dataLoc,'-struct','s','-mat','-append');
        prStr = sprintf('Appended %s to %s',saveName,dataLoc);
    else
        save(dataLoc,'-struct','s','-mat');
        prStr = sprintf('Saved %s to %s',saveName,dataLoc);
    end
    
else % saving as variable
    
    assignin('base',dataLoc,data);
    prStr = sprintf('Assigned %s to base workspace as %s',saveName,dataLoc);
    
end

% set status text
% (if saved to workspace, show in workspace (the fileOrVar-1 input arg))
setStatusTxt([],prStr,'',fileOrVar-1);

end