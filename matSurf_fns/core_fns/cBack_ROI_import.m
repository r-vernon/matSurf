function cBack_ROI_import(src,~)

% preallocate some flags
removedDuplicate = false;
firstROIadded = false;

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

% get valid path
fileTypes = {'*.mat','*.label','*.*'};
[fileOrVar,dataLoc] = UI_loadData(fileTypes);

% load in data
if fileOrVar == 1 && contains(dataLoc,'.label')
    
    % if it's a label file, read in
    fid = fopen(dataLoc,'r') ;
    if fid == -1
        setStatusTxt(sprintf(handles.statTxt,'Could not read %s',dataLoc)); 
        return
    end
    
    % skip first line, then get number of vertices
    fgets(fid);                
    nV = fscanf(fid,'%d\n',1);
    
    % read in rest of data, skipping (%*) all but vertex number
    % (add 1 to vertex to account for FreeSurfer zero indexing)
    data = fscanf(fid, '%d %*f %*f %*f %*f\n',[1 nV])' +1; 
    fclose(fid);

else
    data = loadData(fileOrVar,dataLoc);   
end

aFiles = fieldnames(data);

% work out which to keep
toKeep = structfun(@(x)isfield(x,'ROIs'),data);
data = rmfield(data,aFiles(~toKeep));
aFiles(~toKeep) = [];

% work out how many ROIs there are
nROIs = sum(structfun(@(x)length(x.ROIs.name),data));

newROIs.name = cell(nROIs,1);
newROIs.nVert = zeros(nROIs,1);
newROIs.allVert = cell(nROIs,1);
newROIs.selVert = cell(nROIs,1);
ind = 1;

% for every file in 'data', if subject and hemi matches currVol's subject/hemi, add ROIs
for cFile = 1:length(aFiles)
    if strcmp(data.(aFiles{cFile}).surfDet.subject,currVol.surfDet.subject) && ...
        strcmp(data.(aFiles{cFile}).surfDet.hemi,currVol.surfDet.hemi)
        
        n2add = length(data.(aFiles{cFile}).ROIs.name);
        
        newROIs.name(ind:ind+n2add-1) = data.(aFiles{cFile}).ROIs.name;
        
        newROIs.nVert(ind:ind+n2add-1) = data.(aFiles{cFile}).ROIs.nVert;
        
        newROIs.allVert(ind:ind+n2add-1) = cellfun(@single,...
            data.(aFiles{cFile}).ROIs.allVert,'UniformOutput',false);
        
        newROIs.selVert(ind:ind+n2add-1) = cellfun(@single,...
            data.(aFiles{cFile}).ROIs.selVert,'UniformOutput',false);
        
        ind = ind + n2add;
        
    end
end

% delete any rows that haven't been filled
newROIs.name(ind:end) = [];
newROIs.nVert(ind:end) = [];
newROIs.allVert(ind:end) = [];
newROIs.selVert(ind:end) = [];

% check haven't deleted all ROIs!
if isempty(newROIs.name)
    setStatusTxt(handles.statTxt,'No ROIs to import');
    return;
end

% only keep ROIs with unique names
[~, idx] = unique(newROIs.name, 'stable');
if length(idx) ~= length(newROIs.name), removedDuplicate = 1; end
newROIs.name = newROIs.name(idx);
newROIs.nVert = newROIs.nVert(idx);
newROIs.allVert = newROIs.allVert(idx);
newROIs.selVert = newROIs.selVert(idx);

% add in visible field
newROIs.visible = ones(length(newROIs.name),1,'logical');

%--------------------------------------------------------------------------

% work out if this will be first ROI (+) or not
if currVol.nROIs == 0, firstROIadded = 1; end

% get vertex coords and ind
[vCoords] = currVol.ROI_import(newROIs);

% display the new ROIs
set(handles.brainROI,...
    'XData',vCoords(:,1),...
    'YData',vCoords(:,2),...
    'ZData',vCoords(:,3));

% update ROI popupmenu
handles.selROI.String = currVol.ROIs.name;
handles.selROI.Value  = currVol.currROI;

% if added first ROI, update state, then customise state based on curr. ROI
if firstROIadded, mS_stateControl(f_h,'ra'); end
ROI_stateControl(handles);

if removedDuplicate
   setStatusTxt(handles.statTxt,'Imported ROIs, but removed duplicates','w',1); 
else
    setStatusTxt(handles.statTxt,'Imported ROIs');
end

end
