function [fileOrVar,dataLoc] = UI_loadData(fileTypes,startMode,limUsg)
% function to get valid file or variable name for loading data
%
% (opt.) fileTypes, types of file that can be loaded, input as cell array
%        of character vectors (e.g. {'*.mat','*.*'})
% (opt.) startMode, if 1, initialises to loading a file, if 2, initialises
%        to loading a var
% (opt.) limUsg, if 1, can only load a file, if 2, only a variable
% (ret.) fileOrVar, 1 for loading a file, 2 for loading a variable
% (ret.) dataLoc, location (file or variable name) of data for loading

%  ------------------------------------------------------------------------
% parse inputs

% make sure fileTypes (extensions) are valid, must start with *.
if nargin == 0 || isempty(fileTypes) || (~ischar(fileTypes) || ~iscell(fileTypes)) || ...
        (iscell(fileTypes) && ~all(cellfun(@ischar,fileTypes)))
    fileTypes = '*.*';
else
    fileTypes(~contains(fileTypes,'*.')) = [];
    if isempty(fileTypes), fileTypes = '*.*'; end
end

% check what extensions are allowed
if any(contains(fileTypes,'*.*'))
    allowedFiles = [];
else
    allowedFiles = extractAfter(fileTypes,'.');
end

% need isempty before ~= 1, 2 as get operator...convertible error otherwise
if nargin < 2 || isempty(startMode) || (startMode ~= 1 && startMode ~= 2)
    startMode = 1; % by default load a file
end     

if nargin < 3 || isempty(limUsg) || (limUsg ~= 1 && limUsg ~= 2)
    limUsg = 0;
elseif limUsg == 2
    startMode = 2; % overwrite start mode
end

%  ------------------------------------------------------------------------
% initial setup

% keep track of current modes (1 - File (default), 2 - Var)
fileOrVar = uint8(startMode);

% set some default text options
usageTxt  = {'Enter file path'     , 'Enter var name'    };


%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
loadDataFig = figure('WindowStyle','modal',...
    'Name','Load Data','Tag','loadDataFig','FileName','loadData.fig',...
    'Units','pixels','Position',[100, 100, 460, 115],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');


% grab context menu for copy/paste
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- MODE CHOICE -------------------------------------

% main panel
loadPanel = uibuttongroup(loadDataFig,'Tag','loadPanel','Title','Load:',...
    'Units','pixels','Position',[15,15,80,90],'SelectionChangedFcn',@modeCallback);

% load a file button
loadFile = uicontrol(loadPanel,'Style','radiobutton','String','File',...
    'Tag','loadFile','Position',[10 40 60 24]);

% disable if limiting to vars only
if limUsg == 2, loadFile.Enable = 'off'; end

% load a var button
loadVar = uicontrol(loadPanel,'Style','radiobutton','String','Var',...
    'Tag','loadVar','Position',[10 10 60 24]);

% disable if limiting to files only
if limUsg == 1, loadVar.Enable = 'off'; end

% set starting button, depending on mode
if fileOrVar == 1
    loadPanel.SelectedObject = loadFile;
else
    loadPanel.SelectedObject = loadVar; 
end

%  ========================================================================
%  ---------------------- SAVE LOCATION -----------------------------------

% text entry
nameTxt = uicontrol(loadDataFig,'Style','edit','Tag','nameTxt',...
    'HorizontalAlignment','left','Position',[100,72,323,25],...
    'Callback',@txtCallback,'UIContextMenu',cpMenu);

% browse for folder
browseBut = uicontrol(loadDataFig,'Style','pushbutton','String','...',...
    'Tag','browseBut','Position',[425,72,25,25],'Callback',@browseCallback);
    
% guide text
guideTxt = uicontrol(loadDataFig,'Style','text','String',usageTxt{fileOrVar},...
    'Tag','guideTxt','HorizontalAlignment','right','FontSize',9,...
    'Position',[335,52,100,15]);

% warning text
warnTxt = uicontrol(loadDataFig,'Style','text','String','','Tag','warnTxt',...
    'HorizontalAlignment','left','FontSize',9,'ForegroundColor',[0.9,0,0],...
    'FontAngle','italic','Position',[100,52,210,15],'Visible','off');

%  ========================================================================
%  ---------------------- LOAD/CANCEL/OVERWRITE ---------------------------

% load button (disabled until valid path/variable name provided)
loadBut = uicontrol(loadDataFig,'Style','pushbutton','String','Load',...
    'Tag','loadBut','Position',[370,15,80,25],'Enable','off',...
    'BackgroundColor',[46,204,113]/255,'Callback',@loadCallback);

% cancel button
cancBut = uicontrol(loadDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[280,15,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancCallback);

%  ========================================================================
%  ---------------------- POINTER MANAGER ---------------------------------

% whenever mouse hovers over text entry, change to ibeam
txtEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'ibeam');
iptSetPointerBehavior(nameTxt, txtEnterFcn);

% whenever text hovers over button, change to hand
butEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([loadFile,loadVar,browseBut,loadBut,cancBut],...
    butEnterFcn);

% create a pointer manager
iptPointerManager(loadDataFig);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(loadDataFig,'center');

% make visible
loadDataFig.Visible = 'on';
drawnow; pause(0.05);

% wait until cancel or load clicked
uiwait(loadDataFig); 

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

    function modeCallback(~,~)
        % wipe txt, set guide text
        nameTxt.String = '';
        guideTxt.String = usageTxt{fileOrVar};
    end

% -------------------------------------------------------------------------

    function txtCallback(src,~) 
        % make sure there's no double quotes, then check status
        src.String = char(erase(src.String,{'''','"'}));
        
        % check if entered 'pwd'
        if any(strcmp(src.String,{'pwd','.'}))
            src.String = pwd;
        end
        
        [~] = checkStatus; 
    end

% -------------------------------------------------------------------------

    function browseCallback(~,~)
        
        if fileOrVar == 1 % if in file mode, select file
            
            [selFile,selPath] = uigetfile(fileTypes,'Select file to load');
            
            if ~isequal(selFile,0) % if not clicked cancel
                selPath = fullfile(selPath,selFile);
                nameTxt.String = selPath;
                [~] = checkStatus;
            end
            
        else % if in variable mode, select base variable to overwrite
            
            % see what variables are in base
            baseVar = evalin('base','whos()');
            
            % check if empty, if not construct name list
            if isempty(baseVar)
                varList = {'<empty>'};
            else
                % combine name, size and class into single string
                
                % sort by class
                [~,sortOrd] = sort({baseVar.class});
                baseVar = baseVar(sortOrd);
                
                % make an array of var size as string (i.e. [5,1] = 5x1
                baseVarSize = cellfun(@(x) regexprep(num2str(x),'\s+','x'),...
                    {baseVar.size},'UniformOutput',false);
                
                % combine into single cell array of strings
                varList = cellfun(@(x,y,z) ...
                    sprintf('%s  -  %s %s',x,y,z),{baseVar.name},...
                    baseVarSize,{baseVar.class},'UniformOutput',false);
            end
            
            % create dialogue box allowing user to  select var
            [selVar,didSel] = listdlg('ListString',varList,...
                'PromptString','Select variable to load:',...
                'ListSize',[175,300],'SelectionMode','Single');
            
            % if selected a variable...
            if didSel && ~isempty(baseVar)
                % set variable name, check status
                nameTxt.String = baseVar(selVar).name;
                [~] = checkStatus;
            end  
        end  
    end

% -------------------------------------------------------------------------

    function cancCallback(~,~)
        
        % wipe all output variables
        fileOrVar = []; dataLoc = ''; fileTypes = '';
        
        uiresume(loadDataFig); 
        delete(loadDataFig); % just delete figure
    end

% -------------------------------------------------------------------------

    function loadCallback(~,~)
        
        % first just double check status in case clicked before updating
        [canLoad] = checkStatus;
        if ~canLoad, return; end
        
        % seems like we can save, so get final path or name to load
        dataLoc = nameTxt.String; 

        % delete the figure
        uiresume(loadDataFig); 
        delete(loadDataFig);
    end

% =========================================================================

%  ---------------------- CHECK STATUS ------------------------------------

% =========================================================================

    function canLoad = checkStatus
        % checks the current state of the UI, if it's in valid load state,
        
        canLoad = false;
        
        % can't load file until doesExist = true
        doesExist = false;
        
        % get current text to validate
        dataLoc = nameTxt.String; 
        
        if isempty(dataLoc)
            warnTxt.Visible = 'off';
            loadBut.Enable  = 'off';
            return
        end
        
        %  ----------------------------------------------------------------
        % check if can load, depending on mode
        
        if fileOrVar == 1 && exist(dataLoc,'file') && ~isempty(allowedFiles)
            % if loading a file
            
            % make  sure there's a valid extension
            [~,~,ext] = fileparts(dataLoc);
            if any(contains(ext,allowedFiles))
                doesExist = true;
            end
            
        elseif evalin('base',['exist(''',dataLoc,''',''var'')'])
            % loading a variable
            doesExist = true;
        end
        
        %  ----------------------------------------------------------------
        % parse error index
        
        existsTxt = {'File doesn''t exist' , 'Var doesn''t exist'};
        
        if doesExist
            canLoad = true;
            warnTxt.Visible = 'off';
            loadBut.Enable  = 'on';
        else
            warnTxt.String  = existsTxt{fileOrVar};
            warnTxt.Visible = 'on';
            loadBut.Enable  = 'off';
        end
        
        drawnow; pause(0.05);
    end

end