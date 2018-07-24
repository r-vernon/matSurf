function [surfDet,success] = UI_findSurf(SUBJECTS_DIR)

success = false;

%--------------------------------------------------------------------------
% initial settings

if nargin == 0, SUBJECTS_DIR = ''; end

surfDet = struct('name','','SUBJECTS_DIR',SUBJECTS_DIR,'subject','',...
    'hemi','lh','surfType','inf','sPath','','cPath','');

% create a variable to store paths to check
% in order: custom, FreeSurfer, HCP, current dir
toCheck = false(4,1);
cPath = {}; % custom path(s)

% preallocate sFiles and cFiles so they have persistent scope
sFiles = [];
cFiles = [];

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
findSurfFig = figure('WindowStyle','normal',...
    'Name','Enter SUBJECTS_DIR','Tag','findSurfFig','FileName','findSurf.fig',...
    'Units','pixels','Position',[100, 100, 500, 160],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

%--------------------------------------------------------------------------

% text entry
subDirTxt = uicontrol(findSurfFig,'Style','edit','Tag','subDirTxt',...
    'HorizontalAlignment','left','Position',[15,120,443,25],...
    'String',SUBJECTS_DIR,'Callback',@subDirCallback);

% browse for folder
browseBut = uicontrol(findSurfFig,'Style','pushbutton','String','...',...
    'Tag','browseBut','Position',[460,120,25,25],'Callback',@browseCallback);

% warning text
warnTxt = uicontrol(findSurfFig,'Style','text','String','Invalid path','Tag','warnTxt',...
    'HorizontalAlignment','right','FontSize',8,'ForegroundColor',[0.9,0,0],...
    'FontAngle','italic','Position',[315,45,170,15],'Visible','off');

%--------------------------------------------------------------------------

% hemisphere panel
hemiPanel = uibuttongroup(findSurfFig,'Tag','hemiPanel','Title','Hemi',...
    'Units','pixels','Position',[15,40,70,70]);

% left hemisphere button
leftHemi = uicontrol(hemiPanel,'Style','radiobutton','String','Left',...
    'Tag','leftHemi','Position',[5 25 45 25],'Callback',@hemiCallback);

% right hemisphere button
rightHemi = uicontrol(hemiPanel,'Style','radiobutton','String','Right',...
    'Tag','rightHemi','Position',[5 0 55 25],'Callback',@hemiCallback);

%--------------------------------------------------------------------------

% surfType panel
sTypePanel = uibuttongroup(findSurfFig,'Tag','sTypePanel','Title','Surf Type',...
    'Units','pixels','Position',[90,15,85,95]);

% inflated button
infSurf = uicontrol(sTypePanel,'Style','radiobutton','String','Inflated',...
    'Tag','infSurf','Position',[5 50 70 25],'Callback',@sTypeCallback);

% white button
whSurf = uicontrol(sTypePanel,'Style','radiobutton','String','White',...
    'Tag','whSurf','Position',[5 25 55 25],'Callback',@sTypeCallback);

% pial button
pialSurf = uicontrol(sTypePanel,'Style','radiobutton','String','Pial',...
    'Tag','pialSurf','Position',[5 0 45 25],'Callback',@sTypeCallback);

%--------------------------------------------------------------------------

% subjects drop down
selSubj = uicontrol(findSurfFig,'Style','listbox','String','Select Subject',...
    'Tag','selSubj','Position',[180,15,120,90],'Callback',@selSubjCallback);

% search button
searchBut = uicontrol(findSurfFig,'Style','pushbutton','String','Search',...
    'Tag','searchBut','Position',[405,85,80,25],...
    'Callback',@searchCallback);

% cancel button
cancBut = uicontrol(findSurfFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[315,15,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancCallback);

% load button
loadBut = uicontrol(findSurfFig,'Style','pushbutton','String','Load',...
    'Tag','loadBut','Position',[405,15,80,25],'Enable','off',...
    'BackgroundColor',[46,204,113]/255,'Callback',@loadCallback);

%  ========================================================================
%  ---------------------- POINTER MANAGER ---------------------------------

% whenever mouse hovers over text entry, change to ibeam
txtEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'ibeam');
iptSetPointerBehavior(subDirTxt, txtEnterFcn);

% whenever text hovers over button, change to hand
butEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([browseBut,leftHemi,rightHemi,infSurf,whSurf,...
    pialSurf,selSubj,loadBut,cancBut],butEnterFcn);

% create a pointer manager
iptPointerManager(findSurfFig);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(findSurfFig,'center');

% check if SUBJECTS_DIR been set
if ~isempty(SUBJECTS_DIR)
    [~] = checkSubjDir;
end

% make visible
findSurfFig.Visible = 'on';
drawnow;

% wait until cancel or load clicked
% uiwait(findSurfFig);

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

    function subDirCallback(src,~)
        
        if isempty(src.String), return; end
        
        % make sure there's no double quotes
        src.String = char(erase(src.String,{'''','"'}));
        
        % check if entered 'pwd'
        if any(strcmp(src.String,{'pwd','.'}))
            src.String = pwd;
        end
        
        % make sure it exists
        if ~exist(src.String,'dir')
            % check if e.g. given path to file instead of just path
            testPath = fileparts(src.String);
            if exist(testPath,'dir')
                src.String = testPath;
            else
                set(warnTxt,'String','Invalid path','Visible','on');
                return;
            end
        end
        
        toCheck(:) = 0;
        [~] = checkSubjDir;
    end

    function browseCallback(~,~)
        
        % open dialogue box to select a folder
        startDir = subDirTxt.String;
        if isempty(startDir)
            startDir = pwd;
        end
        selPath = uigetdir(startDir,'Select SUBJECTS_DIR');
        
        % set path and test if it's valid
        if selPath ~= 0
            subDirTxt.String = selPath;
            toCheck(:) = 0;
            [~] = checkSubjDir;
        end
    end

% -------------------------------------------------------------------------
% select subject

    function selSubjCallback(src,~)
        if ischar(src.String)
            surfDet.subject = src.String;
        else
            surfDet.subject = src.String{src.Value};
        end
    end

% -------------------------------------------------------------------------
% search in current directory for valid files

    function searchCallback(src,~)
        
        startDir = subDirTxt.String;
        if isempty(startDir)
            startDir = pwd;
        end
        
        toCheck(1) = 0;
        
        src.String = 'searching';
        drawnow;
        fileChk = dir([startDir,'/**/*h.curv']);
        src.String = 'Search';
        
        if ~isempty(fileChk)
            
            toCheck(1) = 1;
            
            % grab unique folder names
            cPath = unique({fileChk.folder});
        
            [~] = checkSubjDir(1);
        end
        
    end
% -------------------------------------------------------------------------
% cancel and load

    function cancCallback(~,~)
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

    function loadCallback(~,~)
        
        % double check status
        canSave = checkSubjDir(1);
        if ~canSave, return; end
        
        % save out file paths
        surfDet.sPath = fullfile(strrep(surfDet.sPath,'xxREPLACExx',surfDet.subject));
        surfDet.cPath = fullfile(strrep(surfDet.cPath,'xxREPLACExx',surfDet.subject));
        
        % get a valid subject name
        surfDet.subject = UI_getVarName('Enter subject name',...
            erase(surfDet.subject,{'.','/'}));
        
        % contruct a valid surface name 
        surfName = [surfDet.subject,'_',surfDet.hemi,'_',surfDet.surfType];
        surfDet.name = UI_getVarName('Enter surface name',surfName);

        success = true;
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

% -------------------------------------------------------------------------
% hemisphere and surface type callbacks

    function hemiCallback(src,~)
        if strcmp('L',src.String(1))
            surfDet.hemi = 'lh';
        else
            surfDet.hemi = 'rh';
        end
        [~] = checkSubjDir(true);
    end

    function sTypeCallback(src,~)
        switch src.String(1)
            case 'I'
                surfDet.surfType = 'inf';
            case 'W'
                surfDet.surfType = 'wh';
            otherwise
                surfDet.surfType = 'pial';
        end
        [~] = checkSubjDir(true);
    end

%--------------------------------------------------------------------------

    function validateSubjDir
        % checks to see which search possibilies should be followed
        % (likely only one option true so shouldn't be too intensive...)
        % will also try to update with real path (i.e. no ./, /../, ~/)
        %
        % checks for curv file as otherwise too many matches
        
        % grab subjects directory
        SUBJECTS_DIR = subDirTxt.String;
        
        % check if possible freesurfer directory
        fileChk = dir([SUBJECTS_DIR,'/*/surf/*h.curv']);
        if ~isempty(fileChk)
            toCheck(2) = 1; 
            delimLoc = strfind(fileChk(1).folder,'/');
            SUBJECTS_DIR = fileChk(1).folder(1:delimLoc(end-1)-1);
        end
        
        % check if possible hcp directory
        fileChk = dir([SUBJECTS_DIR,'/*/T1w/*/surf/*h.curv']);
        if ~isempty(fileChk)
            toCheck(3) = 1;
            delimLoc = strfind(fileChk(1).folder,'/');
            SUBJECTS_DIR = fileChk(1).folder(1:delimLoc(end-3)-1);
        end
        
        % check if any files in current directory
        fileChk = dir([SUBJECTS_DIR,'/*h.curv']);
        if ~isempty(fileChk)
            toCheck(4) = 1; 
            SUBJECTS_DIR = fileChk(1).folder;
        end
        
        % update string in case it's been expanded
        subDirTxt.String = SUBJECTS_DIR;
    end

%--------------------------------------------------------------------------

    function [aFiles] = checkFilesExist(surf_or_curv)
        % checks if files exist
        % if surf_curv = 'surf', checks for surface, otherwise checks for curv
        
         % work out which hemi we're trying to load
        hemi = [lower(hemiPanel.SelectedObject.String(1)),'h'];
        
        % work out if checking surface (if so which one) or curv
        if strcmp(surf_or_curv(1),'s')
            surfType = lower(sTypePanel.SelectedObject.String);
        else
            surfType = 'curv';
        end
        
        % preallocate for all files
        aFiles = [];
        
        if toCheck(1) % if ran custom search, check that first
            
            aFiles = cell(length(cPath),1);
            
            for currPath = 1:length(cPath)
                tmp = dir([cPath{currPath},'/',hemi,'.',surfType]);
                aFiles{currPath} = tmp.folder;
            end
            
            aFiles(isempty(aFiles)) = [];
            
        elseif toCheck(2)     % check freesurfer possibility
            
            tmp = dir([SUBJECTS_DIR,'/*/surf/',hemi,'.',surfType]);
            aFiles = {tmp.folder};
            
        elseif toCheck(3) % check HCP possibility
            
            tmp = dir([SUBJECTS_DIR,'/*/T1w/*/surf/',hemi,'.',surfType]);
            aFiles = {tmp.folder};
            
        elseif toCheck(4) % check current dir possibility
            
            tmp = dir([SUBJECTS_DIR,'/',hemi,'.',surfType]);
            aFiles = {tmp.folder};
            
        end
        
    end

%--------------------------------------------------------------------------

    function [subjNames] = getSubjNames(valSubjects)
        
        if toCheck(2) || toCheck(3)
            
            % if known file structure (FreeSurfer/HCP), can parse it
            subjNames = regexp(valSubjects,'\w+/(\w+)/surf','tokens');
            subjNames = [subjNames{:}]'; % expand cell of cells to just cell
            
        else
            
            % just return whole path without SUBJECT_DIR!
            subjNames = strrep(valSubjects,subDirTxt.String,'.');
            
        end
    end

%--------------------------------------------------------------------------

    function setFilePaths
        % xxREPLACExx will be replaced by subject when saving out
        
        hemi     = [lower(hemiPanel.SelectedObject.String(1)),'h'];
        surfType = lower(sTypePanel.SelectedObject.String);
        
        if toCheck(2) % if freesurfer path
            
            surfDet.sPath = [SUBJECTS_DIR,'/xxREPLACExx/surf/',hemi,'.',surfType];
            surfDet.cPath = [SUBJECTS_DIR,'/xxREPLACExx/surf/',hemi,'.curv'];
            
        elseif toCheck(3) % if HCP path
            
            surfDet.sPath = [SUBJECTS_DIR,...
                '/xxREPLACEMExx/T1w/xxREPLACExx/surf/',hemi,'.',surfType];
            surfDet.cPath = [SUBJECTS_DIR,...
                '/xxREPLACEMExx/T1w/xxREPLACExx/surf/',hemi,'.curv'];
            
        else % just stored path to file
            
            surfDet.sPath = [SUBJECTS_DIR,'/xxREPLACExx/',hemi,'.',surfType];
            surfDet.cPath = [SUBJECTS_DIR,'/xxREPLACExx/',hemi,'.curv'];
            
        end
    end

%--------------------------------------------------------------------------
    function canSave = checkSubjDir(subjDirSame)
        
        canSave = false;
        
        % if subjDirSame skips checking curvature files
        if nargin == 0, subjDirSame = false; end
        
        % disable warning text at first
        warnTxt.Visible = 'off';
        
        % check subjects directory is valid
        if ~subjDirSame
            validateSubjDir;    
        else
            if isempty(subDirTxt.String), return; end
        end
        
       % check if surface files exist
       sFiles = checkFilesExist('surf');
       
       % if subject directory changed, check if curv files exist
       if ~subjDirSame || isempty(cFiles)
           cFiles = checkFilesExist('curv');
       end

        if ~isempty(sFiles) && ~isempty(cFiles) % if files found

            % get valid subjects (have both surface and curvature file)
            subjNames = getSubjNames(intersect(sFiles,cFiles));
            
        else
            subjNames = '';
        end
        
        % check there were valid subjects
        if ~isempty(subjNames)
            assignin('base','subjNames_b',subjNames);
            selSubj.String = {subjNames{:}};
            loadBut.Enable = 'on';
            surfDet.SUBJECTS_DIR = subDirTxt.String;
            if ischar(selSubj.String)
                surfDet.subject = selSubj.String;
            else
                surfDet.subject = selSubj.String{selSubj.Value};
            end
            setFilePaths;
            canSave = true;
        else
            set(warnTxt,'String','No subjects found','Visible','on');
            set(selSubj,'String','Select Subject','Value',1);
            loadBut.Enable = 'off';
        end
    end
end
