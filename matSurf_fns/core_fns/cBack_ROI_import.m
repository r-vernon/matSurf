function cBack_ROI_import(src,~)

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
        setStatusTxt(sprintf('Could not read %s',dataLoc)); 
        return
    end
    
    % skip first line, then get number of vertices
    fgets(fid);                
    nV = fscanf(fid,'%d\n',1);
    
    % read in rest of data, skipping (%*) all but vertex number
    data = fscanf(fid, '%d %*f %*f %*f %*f\n',[1 nV])'; 
    fclose(fid);
    
    % add 1 to vertex to account for FreeSurfer zero indexing
    data = data + 1;
    
else
    data = loadData(fileOrVar,dataLoc);   
end

aFiles = fieldnames(data);

% work out which to keep
toKeep = structfun(@(x)isfield(x,'ROIs'),data);
data = rmfield(data,aFiles(~toKeep));
aFiles(~toKeep) = [];

% work out how many ROIs there are
nROIs = sum(structfun(@(x)length(x.ROIs),data));

tmpROIs(nROIs+10) = struct('name','','allVert',[],'selVert',[]);
ind = 1;

for cFile = 1:length(aFiles)
    if strcmp(data.(aFiles{cFile}).surfDet.surfName,currVol.surfDet.surfName)
        
        n2add = length(data.(aFiles{cFile}).ROIs);
        tmpROIs(ind:ind+n2add-1) = data.(aFiles{cFile}).ROIs;
        ind = ind + n2add;
        
    end
end
tmpROIs(all(isempty(tmpROIs),'rows')) = [];

[~, idx] = unique({tmpROIs.name}, 'stable');
tmpROIs = tmpROIs(idx);