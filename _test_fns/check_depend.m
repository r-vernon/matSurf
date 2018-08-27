
allFiles = dir('./matSurf_fns/**/*.m');
all_fNames = fullfile({allFiles.folder},{allFiles.name})';
n_fNames = length(all_fNames);

allDep(n_fNames).fName = '';
allDep(n_fNames).pList = [];

wb = waitbar(0,'Processing');

for currFile = 1:n_fNames
    [~,tmp] = matlab.codetools.requiredFilesAndProducts(all_fNames{currFile},'toponly');
    
    if length(tmp) > 1
        allDep(currFile).fName = all_fNames{currFile};
        allDep(currFile).pList = tmp;
    end
    
    waitbar(currFile/n_fNames);
end

close(wb);