function matSurf_pathSetup(baseDir)
% function to setup all necessary paths for matSurf
%
% (opt.) baseDir, base directory of matsurf

if nargin == 0, baseDir = pwd; end

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

% add to path, if it isn't already
if ~contains(path,[fsPaths{1},pathsep])
    addpath(fsPaths{1});
    fprintf('\nAdded %s to Matlab path\n',fsPaths{1});
end

% also just make sure TMPDIR set appropriately for FreeSurfer
% (on my work machine, TMPDIR will default to somewhere without write
% access so causes error)
if isempty(getenv('TMPDIR'))
    setenv('TMPDIR','/tmp'); 
end

%-------------------------------
% add matSurf fns to matlab path

mS_path = [baseDir, '/matSurf_fns'];
if ~contains(path,[mS_path,pathsep])
    addpath(genpath(mS_path));
    fprintf('\nAdded %s to Matlab path\n',mS_path);
end

end