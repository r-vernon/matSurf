function [surfDet,success] = UI_findSurf(SUBJECTS_DIR)

success = false;

%--------------------------------------------------------------------------
% initial settings

if nargin == 0, SUBJECTS_DIR = ''; end

surfDet = struct('name','','SUBJECTS_DIR',SUBJECTS_DIR,'subject','',...
    'hemi','lh','surfType','inf','sPath','','cPath','');

% preallocate (c)urv(Files) so it has persistent scope
cFiles = [];

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
findSurfFig = figure('WindowStyle','modal',...
    'Name','Select surface to load','Tag','findSurfFig','FileName','findSurf.fig',...
    'Units','pixels','Position',[100, 100, 500, 212],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

%--------------------------------------------------------------------------

% guide text
[~] = uicontrol(findSurfFig,'Style','text',...
    'String','Enter subjects directory (SUBJECTS_DIR):','Tag','guideTxt',...
    'HorizontalAlignment','left','Position',[15,182,400,15]);

% text entry
subjDirTxt = uicontrol(findSurfFig,'Style','edit','Tag','subjDirTxt',...
    'HorizontalAlignment','left','Position',[15,155,443,25],...
    'String',SUBJECTS_DIR,'Callback',@subjDirCallback);

% browse for folder
browseBut = uicontrol(findSurfFig,'Style','pushbutton','String','...',...
    'Tag','browseBut','Position',[460,155,25,25],'Callback',@browseCallback);

% path select drop down
selPath = uicontrol(findSurfFig,'Style','popupmenu','String','Select path',...
    'Tag','selPath','Position',[15,120,385,25]);

% warning text
warnTxt = uicontrol(findSurfFig,'Style','text','String','Invalid path','Tag','warnTxt',...
    'HorizontalAlignment','right','FontSize',8,'ForegroundColor',[0.9,0,0],...
    'FontAngle','italic','Position',[235,45,250,15],'Visible','on');

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
infSurf = uicontrol(sTypePanel,'Style','radiobutton','String','inflated',...
    'Tag','infSurf','Position',[5 50 70 25],'Callback',@sTypeCallback);

% white button
whSurf = uicontrol(sTypePanel,'Style','radiobutton','String','white',...
    'Tag','whSurf','Position',[5 25 55 25],'Callback',@sTypeCallback);

% pial button
pialSurf = uicontrol(sTypePanel,'Style','radiobutton','String','pial',...
    'Tag','pialSurf','Position',[5 0 45 25],'Callback',@sTypeCallback);

%--------------------------------------------------------------------------

% search button
searchBut = uicontrol(findSurfFig,'Style','pushbutton','String','Search',...
    'Tag','searchBut','Position',[405,121,80,24],...
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
iptSetPointerBehavior(subjDirTxt, txtEnterFcn);

% whenever text hovers over button, change to hand
butEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([browseBut,leftHemi,rightHemi,infSurf,whSurf,...
    pialSurf,selPath,searchBut,cancBut,loadBut],butEnterFcn);

% create a pointer manager
iptPointerManager(findSurfFig);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(findSurfFig,'center');

% check if SUBJECTS_DIR been set
if ~isempty(SUBJECTS_DIR)
    setCurvFiles;
end

% make visible
findSurfFig.Visible = 'on';
drawnow;

% wait until cancel or load clicked
uiwait(findSurfFig);

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

% entered new subjects directory

    function subjDirCallback(src,~)
        
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
        
        setCurvFiles;
    end

% -------------------------------------------------------------------------
% browsed for new subjects directory

    function browseCallback(~,~)
        
        % open dialogue box to select a folder
        startDir = subjDirTxt.String;
        if isempty(startDir)
            startDir = pwd;
        end
        pathBrowse = uigetdir(startDir,'Select subjects directory');
        
        % set path and test if it's valid
        if pathBrowse ~= 0
            subjDirTxt.String = pathBrowse;
            setCurvFiles;
        end
    end

% -------------------------------------------------------------------------
% hemisphere and surface type callbacks

    function hemiCallback(src,~)
        if strcmp('L',src.String(1))
            surfDet.hemi = 'lh';
        else
            surfDet.hemi = 'rh';
        end
        checkSubjDir;
    end

    function sTypeCallback(src,~)
        switch src.String(1)
            case 'i'
                surfDet.surfType = 'inf';
            case 'w'
                surfDet.surfType = 'wh';
            otherwise
                surfDet.surfType = 'pial';
        end
        checkSubjDir;
    end

% -------------------------------------------------------------------------
% search in current directory for valid files

    function searchCallback(src,~)
        
        cFiles = {};
        
        startDir = subjDirTxt.String;
        if isempty(startDir)
            startDir = pwd;
        end
        
        % change search to searching
        src.String = 'Searching';
        drawnow;
        
        % check for any files (note '**' requires Matlab R2016+ I think)
        fileChk = dir([startDir,'/**/*h.curv']);
        
        % change back
        src.String = 'Search';

        if ~isempty(fileChk)
            % grab unique folder names
            cFiles = unique({fileChk.folder});
            checkSubjDir;
        else
            set(warnTxt,'String','No valid paths found','Visible','on');
            set(selPath,'String','Select Path','Value',1);
            loadBut.Enable = 'off';
        end
        
    end

% -------------------------------------------------------------------------
% cancel

    function cancCallback(~,~)
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

% -------------------------------------------------------------------------
% load

    function loadCallback(~,~)
        
        % grab the paths to surface and curvature
        if ischar(selPath.String)
            currPath = selPath.String;
        else
            currPath = selPath.String{selPath.Value};
        end
        targSurf = [currPath,'/',surfDet.hemi,'.',sTypePanel.SelectedObject.String];
        targCurv = [currPath,'/',surfDet.hemi,'.curv'];
        
        if ~exist(targSurf,'file') || ~exist(targCurv,'file')
            checkSubjDir;
            return
        end
        
        % see if we can find a potential subject name
        surfLoc = strfind(targSurf,'/surf');
        if ~isempty(surfLoc)
            delimLoc = strfind(targSurf,'/');
            subjName = targSurf(max(delimLoc(delimLoc < surfLoc))+1:surfLoc-1);
        else
            subjName = currPath;
        end
            
        % get a valid subject name
        surfDet.subject = UI_getVarName('Enter subject name',subjName);
        
        % contruct a valid surface name
        surfName = [surfDet.subject,'_',surfDet.hemi,'_',surfDet.surfType];
        surfDet.name = UI_getVarName('Enter surface name',surfName);
        
        % save out subject directory
        surfDet.SUBJECTS_DIR = subjDirTxt.String;

        % save out paths
        surfDet.sPath = targSurf;
        surfDet.cPath = targCurv;
        
        success = true;
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

% =========================================================================

%  ---------------------- CHECK FUNCTION ----------------------------------

% =========================================================================

    function setCurvFiles
        % sets location of curv files
        
        cFiles = {};
        
        % set some possible search paths to check over
        % 1 - Freesurfer, 2 - HCP, 3 - curDir, 4 - curDir/*/
        srchPaths = {'/*/surf/*h.curv','/*/T1w/*/surf/*h.curv','/*h.curv','/*/*h.curv'};
        
        % search through search paths
        for ind = 1:4
            fileChk = dir([subjDirTxt.String,srchPaths{ind}]);
            if ~isempty(fileChk)
                cFiles = unique({fileChk.folder});
                break;
            end
        end
        
        % if we've found files, check if they're valid, otherwise error
        if ~isempty(cFiles)
            checkSubjDir;
        else
            set(warnTxt,'String','No valid paths found (try searching)','Visible','on');
            set(selPath,'String','Select Path','Value',1);
            loadBut.Enable = 'off';
        end
    end
        
    function checkSubjDir
        
        if isempty(subjDirTxt.String), return; end
        if isempty(cFiles), setCurvFiles; end
        
        % disable warning text at first
        warnTxt.Visible = 'off';
        
        % check for requested surface files
        % also double checking curv in case e.g. left exists but not right
        targSurf = ['/',surfDet.hemi,'.',sTypePanel.SelectedObject.String];
        targCurv = ['/',surfDet.hemi,'.curv'];
        found_targSurf = false(length(cFiles),1);
        
        % for each curv file, check if there's a corresponding surf file
        for currFile = 1:length(cFiles)
            if exist([cFiles{currFile},targSurf],'file') && ...
                    exist([cFiles{currFile},targCurv],'file')
                
                found_targSurf(currFile) = 1;
                
            end
        end
        
        % delete any saved curv files, when couldn't find surf file
        tmp_cFiles = cFiles;
        tmp_cFiles(~found_targSurf) = [];

        % use simple heuristic to preserve path string if posssible
        if length(selPath.String) == length(tmp_cFiles)
            newVal = selPath.Value;
        else
            newVal = 1;
        end
        
        % check there were valid subjects
        if ~isempty(tmp_cFiles)
            set(selPath,'String',tmp_cFiles,'Value',newVal);
            loadBut.Enable = 'on';    
        else
            set(warnTxt,'String','No valid paths found','Visible','on');
            set(selPath,'String','Select Path','Value',1);
            loadBut.Enable = 'off';
        end
        
        drawnow;
        
    end
            
end     
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            