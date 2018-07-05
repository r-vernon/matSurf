function surface_setDetails(obj,surfPath,curvPath,surfName)
% function to set surface details
%
% (req.) surfPath, path to surface
% (req.) curvPath, path to curvature
% (opt.) surfName, name of surface
% (set.) surfDet, structure containing surfName, surfPath, curvPath

% can potentially not set surfName, as will likely set it correctly
if nargin < 3 || isempty(surfName), surfName = ''; end

% =========================================================================
% test to see if any inputs given as cell for whatever reason...

if iscell(surfName) && isscalar(surfName)
    surfName = surfName{1};
end

if iscell(surfPath) && isscalar(surfPath)
    surfPath = surfPath{1};
end

if iscell(curvPath) && isscalar(curvPath)
    curvPath = curvPath{1};
end

% =========================================================================
% do some other basic validations

% make sure the paths to surface and curvature are valid
if ~ischar(surfPath) || ~exist(surfPath,'file')
    error('Could not find requested surface\n(%s)\n',surfPath);
end
if ~ischar(curvPath) || ~exist(curvPath,'file')
    error('Could not find curvature information\n(%s)\n',curvPath);
end

% see if the surface name is valid
% if it isn't, construct best guess at surface name
if isempty(surfName) || ~ischar(surfName)
    
    % see if we can parse surfPath or curvPath for required information
    surfDet = strsplit(surfPath,'/');
    
    if strcmp(surfDet(end-1),'surf') && regexpi(surfDet{end},'^[lr]h.[a-z]+$')
        % highly likely loaded in freesurfer surface so parse that for surfName
        surfName = strcat(surfDet{end-2},'_',...
            extractBefore(surfDet{end},'.'));
    else
        curvDet = strsplit(curvPath,'/');
        
        if strcmp(curvDet(end-1),'surf') && regexpi(curvDet{end},'^[lr]h.[a-z]+$')
            % highly likely loaded in freesurfer curvature so parse that for surfName
            surfName = strcat(curvDet{end-2},'_',...
                extractBefore(curvDet{end},'.'));
        else
            % if all else files just grab basename!
            [~,surfName,~] = fileparts(surfPath);
            surfName = erase(surfName,'.nii'); % in case .nii.gz file
        end
    end
    
    % tell user setting new name
    warning('Could not set requested name, using %s instead',surfName);
    
end

% =========================================================================
% save out surface details

obj.surfDet = struct('surfName',surfName,'surfPath',surfPath,...
    'curvPath',curvPath);

end