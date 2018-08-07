function [data] = loadData(fileOrVar,dataLoc,var2load)
% function to load data, either from file or variable
% assumes inputs from UI_loadData, so does not do much validation!
%
% (req.) fileOrVar, 1 for loading a file, 2 for loading a variable
% (req.) dataLoc, location of file or variable name to load
% (opt.) var2load, restrict loading to specific variable contained either
%        in .mat file or struct workspace variable
% (ret.) data, loaded data (empty if couldn't load)

data = [];

% check if var2load is valid
if nargin < 3 || ~isvarname(var2load)
    var2load = '';
end 

if fileOrVar == 1 % saving as file
    
    if isempty(var2load)
        data = load(dataLoc);
        prStr = sprintf('Loaded %s',dataLoc);
    else
        tmpData = load(dataLoc,var2load);
        if isempty(fieldnames(tmpData))
            prStr = sprintf('Could not load %s from %s',var2load,dataLoc);
        else
            data = tmpData.(var2load);
            prStr = sprintf('Loaded %s from %s',var2load,dataLoc);
        end
    end
    
else % saving as variable
    
    if isempty(var2load)
        data = evalin('base',dataLoc);
        prStr = sprintf('Loaded %s from base workspace',dataLoc);
    else
        tmpData = evalin('base',dataLoc);
        if ~isstruct(tmpData) || isempty(fieldnames(tmpData))
            prStr = sprintf('Could not find %s in base worskpace variable %s',...
                var2load,dataLoc);
        else
            data = tmpData.(var2load);
            prStr = sprintf('Loaded %s from base workspace variable %s',...
                var2load,dataLoc);
        end
    end
end

% set status text
% (if loaded from workspace, show in workspace (the fileOrVar-1 input arg))
setStatusTxt([],prStr,'',fileOrVar-1);

end