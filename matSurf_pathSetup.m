function matSurf_pathSetup(baseDir)
% function to setup all necessary paths for matSurf
%
% (opt.) baseDir, base directory of matsurf

if nargin == 0, baseDir = pwd; end

allPaths = {};
pathsToAdd = '';

%----------------------------------------------------
% first work out where the FreeSurfer directory is...

% set some possible FreeSurfer paths (in ascending probability order)
fsPaths = {...
    '/usr/lib/freesurfer-6.0/matlab',...
    '/usr/local/freesurfer/matlab',...
    strcat(getenv('FREESURFER_HOME'),'/matlab')...
    };

% work backworks through list, testing if each path exists (de. if not)
for currPath = length(fsPaths):-1:1
    if ~exist(fsPaths{currPath},'file'), fsPaths(currPath) = []; end
end

% if haven't found suitable path, ask user for it
if isempty(fsPaths)
    fsPaths{1} = input('Enter path to FreeSurfer matlab dir\n','s');
end

% also just make sure TMPDIR set appropriately for FreeSurfer
% (on my work machine, TMPDIR will default to somewhere without write
% access so causes error)
if isempty(getenv('TMPDIR'))
    setenv('TMPDIR','/tmp'); 
end

%---------------------------------------
% add all remaining paths to matlab path

% create cell of all required paths
allPaths{1} = [fsPaths{1},              pathsep]; % FreeSurfer matlab dir
allPaths{2} = [baseDir, '/matSurf_fns', pathsep]; % matSurf callback fns
allPaths{3} = [baseDir, '/camControl',  pathsep]; % camera control fns
allPaths{4} = [baseDir, '/misc_figs',   pathsep]; % misc. figures
allPaths{5} = [baseDir, '/misc_fns',    pathsep]; % misc. functions

% work out which paths need adding
for currPath = 1:length(allPaths)
    if ~contains(path,allPaths{currPath})
        pathsToAdd = strcat(pathsToAdd,allPaths{currPath});
    end
end

% add them (doing all in one go should be faster than individually)
if ~isempty(pathsToAdd)
    addpath(pathsToAdd);
    fprintf(['\nAdding following to Matlab path: \n',strrep(pathsToAdd,':','\n'),'\n']);
end

end