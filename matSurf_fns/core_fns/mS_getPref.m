function [mS_pref] = mS_getPref(baseDir)
% function to get matSurf preferences, either from local file or via matlab
% preferences
%
% (opt.) baseDir, base directory of matsurf

if nargin == 0, baseDir = pwd; end

%--------------------------------------------------------------------------
% setup defaults

% working folders, matSurf_dir, SUBJECTS_DIR and data_dir
mS_pref.matSurf_dir = baseDir;
mS_pref.SUBJECTS_DIR = [baseDir,'/Data'];
mS_pref.data_dir = [baseDir,'/Data/R3517/data'];

% vertex marker preferences (length, radius, colour)
mS_pref.vMarkL = 5;
mS_pref.vMarkR = 1;
mS_pref.vMarkC = [0,1,0];

