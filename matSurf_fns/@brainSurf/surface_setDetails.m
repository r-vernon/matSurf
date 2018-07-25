function surface_setDetails(obj,varargin)
% function to set surface details
%
% (req.) either:
%        - surfDet, structure containing relavent fields
%        - name pair arguments (e.g. 'hemi','lh') referencing one or more 
%          of the fields contained in surfDet (see below)
% (set.) surfDet, structure containing:
%        - SUBJECTS_DIR, search path for surface
%        - subject,      name of subject
%        - surfName,     name of surface
%        - hemi,         surface hemisphere (lh - left, rh - right)
%        - surfType,     (inf)lated, (wh)ite or (pial)
%        - surfPath,     path to surface file
%        - curvPath,     path to curv file

% anonymous function to check paths
validPath = @(x) ~isempty(x) && ischar(x) && exist(x,'file');

% parse arguments in
% if passed surfDet struct, will expand and fill fields
p = inputParser;
addParameter(p,'SUBJECTS_DIR','',@(x)ischar(x));
addParameter(p,'subject','',@(x)isvarname(x));
addParameter(p,'surfName','',@(x)isvarname(x));
addParameter(p,'hemi','',@(x)ischar(x));
addParameter(p,'surfType','',@(x)ischar(x));
addParameter(p,'surfPath','',validPath);
addParameter(p,'curvPath','',validPath);
parse(p,varargin{:});

% set all the fields that can be set
allFields = {'SUBJECTS_DIR','subject','surfName','hemi',...
    'surfType','surfPath','curvPath'};

% loop over all fields, and update those that aren't empty
for currField = allFields
    if ~isempty(p.Results.(currField{1}))
        obj.surfDet.(currField{1}) = p.Results.(currField{1});
    end
end

% copy out a few variables just for readability
surfName = obj.surfDet.surfName;
surfPath = obj.surfDet.surfPath;
curvPath = obj.surfDet.curvPath;

% =========================================================================
% make sure surfPath and curvPath are set at least!

if ~validPath(surfPath)
    error('Could not find requested surface\n(%s)\n',surfPath);
end

if ~validPath(curvPath) 
    error('Could not find curvature information\n(%s)\n',curvPath);
end

% =========================================================================
% see if we can validate surfName

% see if the surface name is set
% if it isn't, construct best guess at surface name
if isempty(surfName) 
    
    % see if we can parse surfPath or curvPath for required information
    surfDet = strsplit(surfPath,'/');
    
    if strcmp(surfDet(end-1),'surf') && regexpi(surfDet{end},'^[lr]h.[a-z]+$')
        % highly likely loaded in freesurfer surface so parse that for surfName
        surfName = strcat(surfDet{end-2},'_',strrep(surfDet{end},'.','_'));
    else
        curvDet = strsplit(curvPath,'/');
        
        if strcmp(curvDet(end-1),'surf') && regexpi(curvDet{end},'^[lr]h.[a-z]+$')
            % highly likely loaded in freesurfer curvature so parse that for surfName
            surfName = strcat(curvDet{end-2},'_',extractBefore(curvDet{end},'.'));
        else
            % if all else files just grab basename!
            [~,surfName,~] = fileparts(surfPath);
            surfName = erase(surfName,'.nii'); % in case .nii.gz file
        end
    end
    
    % set surface name if changed
    obj.surfDet.surfName = surfName;
end

end