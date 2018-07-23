function [surfDet,success] = UI_findSurf(SUBJECTS_DIR)

success = false;

%--------------------------------------------------------------------------
% initial settings

if nargin == 0, SUBJECTS_DIR = ''; end

surfDet = struct('SUBJECTS_DIR',SUBJECTS_DIR,'subject','',...
    'hemi','lh','surfType','inf');

% preallocate cFiles so they're saved across subjDir checks
cFiles = [];

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
findSurfFig = figure('WindowStyle','normal',...
    'Name','Enter SUBJECTS_DIR','Tag','findSurfFig','FileName','findSurf.fig',...
    'Units','pixels','Position',[100, 100, 480, 160],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

%--------------------------------------------------------------------------

% text entry
subDirTxt = uicontrol(findSurfFig,'Style','edit','Tag','subDirTxt',...
    'HorizontalAlignment','left','Position',[15,120,423,25],...
    'String',SUBJECTS_DIR,'Callback',@subDirCallback);

% browse for folder
browseBut = uicontrol(findSurfFig,'Style','pushbutton','String','...',...
    'Tag','browseBut','Position',[440,120,25,25],'Callback',@browseCallback);

% warning text
warnTxt = uicontrol(findSurfFig,'Style','text','String','Invalid path','Tag','warnTxt',...
    'HorizontalAlignment','right','FontSize',8,'ForegroundColor',[0.9,0,0],...
    'FontAngle','italic','Position',[295,45,170,15],'Visible','off');

%--------------------------------------------------------------------------

% hemisphere panel
hemiPanel = uibuttongroup(findSurfFig,'Tag','hemiPanel','Title','Hemisphere',...
    'Units','pixels','Position',[15,40,100,70]);

% left hemisphere button
leftHemi = uicontrol(hemiPanel,'Style','radiobutton','String','Left',...
    'Tag','leftHemi','Position',[5 25 45 25],'Callback',@hemiCallback);

% right hemisphere button
rightHemi = uicontrol(hemiPanel,'Style','radiobutton','String','Right',...
    'Tag','rightHemi','Position',[5 0 55 25],'Callback',@hemiCallback);

%--------------------------------------------------------------------------

% surfType panel
sTypePanel = uibuttongroup(findSurfFig,'Tag','sTypePanel','Title','Surface Type',...
    'Units','pixels','Position',[130,15,100,95]);

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
selSubj = uicontrol(findSurfFig,'Style','popupmenu','String','Select Subject',...
    'Tag','selSubj','Position',[345,85,120,25],'Callback',@selSubjCallback);

% load button
loadBut = uicontrol(findSurfFig,'Style','pushbutton','String','Load',...
    'Tag','loadBut','Position',[385,15,80,25],'Enable','off',...
    'BackgroundColor',[46,204,113]/255,'Callback',@loadCallback);

% cancel button
cancBut = uicontrol(findSurfFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[295,15,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancCallback);

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
    checkSubjDir;
end

% make visible
findSurfFig.Visible = 'on';
drawnow;

% wait until cancel or load clicked
uiwait(findSurfFig);

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

    function subDirCallback(src,~)
        % make sure there's no double quotes, then check subj dir
        src.String = char(erase(src.String,{'''','"'}));
        checkSubjDir;
    end

% -------------------------------------------------------------------------

    function browseCallback(~,~)
        
        % open dialogue box to select a folder
        startDir = subDirTxt.String;
        if ~exist(startDir,'dir')
            startDir = fileparts(startDir);
            if ~exist(startDir,'dir')
                startDir = pwd;
            end
        end
        selPath = uigetdir(startDir,'Select SUBJECTS_DIR');
        
        % set path and test if it's valid
        if selPath ~= 0
            subDirTxt.String = selPath;
            checkSubjDir;
        end
    end

% -------------------------------------------------------------------------

    function selSubjCallback(src,~)
        surfDet.subject = src.String{src.Value};
    end

% -------------------------------------------------------------------------

    function cancCallback(~,~)
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

% -------------------------------------------------------------------------

    function loadCallback(~,~)
        success = true;
        uiresume(findSurfFig);
        delete(findSurfFig); % just delete figure
    end

% -------------------------------------------------------------------------

    function hemiCallback(src,~)
        if strcmp('L',src.String(1))
            surfDet.hemi = 'lh';
        else
            surfDet.hemi = 'rh';
        end
        checkSubjDir(true);
    end

% -------------------------------------------------------------------------

    function sTypeCallback(src,~)
        switch src.String(1)
            case 'I'
                surfDet.surfType = 'inf';
            case 'W'
                surfDet.surfType = 'wh';
            otherwise
                surfDet.surfType = 'pial';
        end
        checkSubjDir(true);
    end

%--------------------------------------------------------------------------

    function checkSubjDir(subjDirSame)
        
        % if subjDirSame skips checking curvature files
        if nargin == 0, subjDirSame = false; end
        
        % disable warning text at first
        warnTxt.Visible = 'off';
        
        % grab SUBJECTS_DIR
        SUBJECTS_DIR = subDirTxt.String;
        
        % make sure it's been set
        if isempty(SUBJECTS_DIR)
            return;
        end
        
        % make sure it exists
        if ~exist(SUBJECTS_DIR,'dir')
            set(warnTxt,'String','Invalid path','Visible','on');
            return;
        end
        
        % work out what we're trying to load
        h2ld = lower(hemiPanel.SelectedObject.String(1));
        s2ld = lower(sTypePanel.SelectedObject.String);
        
        % first check if SUBJECTS_DIR is a standard FreeSurfer directory
        sFiles = dir([SUBJECTS_DIR,'/*/surf/',h2ld,'h.',s2ld]);
        
        if ~isempty(sFiles)
            sPath = '/*/surf/';
            
            % update SUBJECTS_DIR with real path (no ./, ./../, ~/)
            SUBJECTS_DIR = regexp(sFiles(1).folder,'(.+)/\w+/surf','tokens');
            SUBJECTS_DIR = SUBJECTS_DIR{:}{:};
            subDirTxt.String = SUBJECTS_DIR;
            
        else
            
            % check if SUBJECTS_DIR is a HCP data set
            sFiles = dir([SUBJECTS_DIR,'/*/T1w/*/surf/',h2ld,'h.',s2ld]);
            
            if ~isempty(sFiles)
                sPath = '/*/T1w/*/surf/';
                
                % update SUBJECTS_DIR with real path (no ./, ./../, ~/)
                SUBJECTS_DIR = regexp(sFiles(1).folder,'(.+)/\w+/T1w/','tokens');
                SUBJECTS_DIR = SUBJECTS_DIR{:}{:};
                subDirTxt.String = SUBJECTS_DIR;
                
            else
                sPath = '';
            end
        end
        
        if ~isempty(sPath) % if files found
            
            if ~subjDirSame
                % if subject dir has changed as well, update curv files list
                cFiles = dir([SUBJECTS_DIR,sPath,h2ld,'h.curv']);
            end
            
            % get valid subjects (have both surface and curvature file)
            valSubjects = regexp(intersect({sFiles.folder},{cFiles.folder}),...
                '\w+/(\w+)/surf','tokens');
            valSubjects = [valSubjects{:}]; % expand cell of cells to just cell
        else
            valSubjects = '';
        end

        % check there were valid subjects
        if ~isempty(valSubjects)
            selSubj.String = [valSubjects{:}];
            loadBut.Enable = 'on';
            surfDet.SUBJECTS_DIR = subDirTxt.String;
            surfDet.subject = selSubj.String{selSubj.Value};
        else
            set(warnTxt,'String','No subjects found','Visible','on');
            set(selSubj,'String','Select Subject','Value',1);
            loadBut.Enable = 'off';
        end
    end
end
