function cBack_ROI_import(src,~)

% get data
f_h = getFigHandle(src);
currVol = getappdata(f_h,'currVol'); 
handles = getappdata(f_h,'handles');

path = '/storage/matSurf/R3517_rh_ROIs.mat';
tmp = load(path);
aFiles = fieldnames(tmp);

% work out which to keep
toKeep = structfun(@(x)isfield(x,'ROIs'),tmp);
tmp = rmfield(tmp,aFiles(~toKeep));
aFiles(~toKeep) = [];

% work out how many ROIs there are
nROIs = sum(structfun(@(x)length(x.ROIs),tmp));

tmpROIs(nROIs+10) = struct('name','','allVert',[],'selVert',[]);
ind = 1;

for cFile = 1:length(aFiles)
    if strcmp(tmp.(aFiles{cFile}).surfDet.surfName,currVol.surfDet.surfName)
        
        n2add = length(tmp.(aFiles{cFile}).ROIs);
        tmpROIs(ind:ind+n2add-1) = tmp.(aFiles{cFile}).ROIs;
        ind = ind + n2add;
        
    end
end
tmpROIs(all(isempty(tmpROIs),'rows')) = [];

[~, idx] = unique({tmpROIs.name}, 'stable');
tmpROIs = tmpROIs(idx);