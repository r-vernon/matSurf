function [saveDataFig,success] = UI_saveData(data,defName,startMode,varOnly)
% function to allow saving data, either in .mat file or in workspace
%
% (req.) data, data to save
% (opt.) defName, default name to save data as
% (opt.) startMode, if 1, initialises to saving as file, if 2, initialises
%        to saving as var
% (opt.) varOnly, if true, can only save as variable, not file
% (ret.) saveDataFig, figure handle to main figure
% (ret.) success, true if saved successfully

success = false;

%  ------------------------------------------------------------------------
% parse inputs

if nargin < 2, defName = ''; end % will deal with defName shortly

if nargin < 3 || isempty(startMode) || (startMode ~= 1 || startMode ~= 2)
    startMode = 1; % by default save as file
end     

if nargin < 4 || isempty(varOnly)
    varOnly = false; 
elseif varOnly
    startMode = 2; % overwrite start mode
end

% get backup name (note: inputname(1) gets var name of 'data')
altName = inputname(1);

% check defName and altName, preferring to use defName where possible
if ~isvarname(defName)
    if isvarname(altName)
        defName = altName;
    else
        defName = '';
        altName = 'data';
    end
else
    altName = defName;
end

%  ------------------------------------------------------------------------
% initial setup

% check if can use default name
defOK = false(2,1);
if ~isempty(defName)
    if ~exist([pwd,'/',defName,'.mat'],'file'), defOK(1) = 1; end
    if evalin('base',['~exist(''',defName,''',''var'')']), defOK(2) = 1; end
end

% keep track of current modes (1 - File (default), 2 - Var)
currMode = uint8(startMode);
canOvrWrite = false; % whether can overwrite or not

% set some default text options
usageTxt  = {'Enter file path'     , 'Enter var name'    };
existsTxt = {'File already exists' , 'Var already exists'};
invalName = {'Invalid filename'    , 'Invalid var name'  };
invalPath =  'Invalid file path';

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
saveDataFig = figure('WindowStyle','modal',...
    'Name','Save Data','Tag','saveDataFig','FileName','saveData.fig',...
    'Units','pixels','Position',[100, 100, 460, 115],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

%  ========================================================================
%  ---------------------- MODE CHOICE -------------------------------------

% main panel
savePanel = uibuttongroup(saveDataFig,'Tag','savePanel','Title','Save as',...
    'Units','pixels','Position',[15,15,80,90],'SelectionChangedFcn',@modeCallback);

% save as file button
saveFile = uicontrol(savePanel,'Style','radiobutton','String','File',...
    'Tag','saveFile','Position',[10 40 60 24]);

% disable if varOnly
if varOnly, saveFile.Enable = 'off'; end

% save as var button
saveVar = uicontrol(savePanel,'Style','radiobutton','String','Var',...
    'Tag','saveVar','Position',[10 10 60 24]);

% set starting button, depending on mode
if currMode == 1
    savePanel.SelectedObject = saveFile;
else
    savePanel.SelectedObject = saveVar; 
end

%  ========================================================================
%  ---------------------- SAVE LOCATION -----------------------------------

% text entry
nameTxt = uicontrol(saveDataFig,'Style','edit','Tag','nameTxt',...
    'HorizontalAlignment','left','Position',[100,72,323,25],...
    'Callback',@txtCallback);

% if default name okay, initialise text with save possibility
if currMode == 1 
    if defOK(1), nameTxt.String = [pwd,'/',defName,'.mat']; end
elseif defOK(2), nameTxt.String = defName; 
end

% browse for folder
uicontrol(saveDataFig,'Style','pushbutton','String','...',...
    'Tag','browseBut','Position',[425,72,25,25],'Callback',@browseCallback);
    
% guide text
guideTxt = uicontrol(saveDataFig,'Style','text','String',usageTxt{currMode},...
    'Tag','guideTxt','HorizontalAlignment','right','FontSize',9,...
    'Position',[335,52,100,15]);

% warning text
warnTxt = uicontrol(saveDataFig,'Style','text','String','','Tag','warnTxt',...
    'HorizontalAlignment','left','FontSize',9,'ForegroundColor',[0.9,0,0],...
    'FontAngle','italic','Position',[100,52,210,15],'Visible','off');

%  ========================================================================
%  ---------------------- SAVE/CANCEL/OVERWRITE ---------------------------

% save button (disabled until valid path/variable name provided)
saveBut = uicontrol(saveDataFig,'Style','pushbutton','String','Save',...
    'Tag','saveBut','Position',[370,15,80,25],'Enable','off',...
    'BackgroundColor',[46,204,113]/255,'Callback',@saveCallback);

% cancel button
uicontrol(saveDataFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[280,15,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancCallback);

% overwrite toggle
ovrWrBut = uicontrol(saveDataFig,'Style','checkbox','String','Overwrite?',...
    'Tag','ovrWrBut','FontSize',9,'Position',[101,26,100,15],...
    'Callback',@ovrWrCallback,'Visible','off');

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(saveDataFig,'center');

% check status of inputs
[~] = checkStatus;

% make visible
saveDataFig.Visible = 'on';
drawnow;

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

    function modeCallback(~,event)
        
        % wipe txt (will insert defName if possible shortly)
        nameTxt.String = '';
        
        % work out which mode we're in and set default text if possible
        switch event.NewValue.String
            case 'File'
                currMode = 1;
                if defOK(1), nameTxt.String = [pwd,'/',defName,'.mat']; end
            otherwise
                currMode = 2;
                if defOK(2), nameTxt.String = defName; end
        end
        
        % set guide text
        guideTxt.String = usageTxt{currMode};
        
        % check status
        [~] = checkStatus;
        
    end

% -------------------------------------------------------------------------

    function txtCallback(~,~) 
        [~] = checkStatus; % just check status
    end

% -------------------------------------------------------------------------

    function browseCallback(~,~)
        
        if currMode == 1 % if in file mode, select folder
            
            % open dialogue box to select a folder
            selPath = uigetdir(pwd,'Select save location');
            
            if defOK(1)
                selPath = fullfile(selPath,[defName,'.mat']);
                nameTxt.String = selPath;
                [~] = checkStatus;
            else
                nameTxt.String = selPath;
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
                'PromptString','Select variable to replace:',...
                'ListSize',[175,300],'SelectionMode','single');
            
            % if selected a variable...
            if didSel && ~isempty(baseVar)
                
                % set variable name and allow overwriting
                nameTxt.String = baseVar(selVar).name;
                ovrWrBut.Value = 1;
                
                % check status
                [~] = checkStatus;
                
            end  
        end  
    end

% -------------------------------------------------------------------------

    function cancCallback(~,~)
        delete(saveDataFig); % just delete figure
    end

% -------------------------------------------------------------------------

    function saveCallback(~,~)
        
        % first just double check status in case clicked before updating
        [canSave] = checkStatus;
        if ~canSave, return; end
        
        % seems like we can save, so might as well do so!
        % get path or name to save to
        currTxt = nameTxt.String; 
        
        if currMode == 1
            % make sure filename ends with .mat
            [~,currName,currExt] = fileparts(currTxt);
            if ~strcmp(currExt,'.mat')
                currTxt = strcat(currName,'.mat'); 
            end
            save(currTxt,'data','-mat');
            fprintf('Saved %s to %s\n',altName,currTxt);
        else
            assignin('base',currTxt,data);
            fprintf('Saved %s to workspace as %s\n',altName,currTxt);
        end
        
        % delete the figure
        success = true;
        delete(saveDataFig);
    end

% -------------------------------------------------------------------------

    function ovrWrCallback(~,~)
        
        % see if status changed
        [~] = checkStatus;
        
    end

% =========================================================================

%  ---------------------- CHECK STATUS ------------------------------------

% =========================================================================

    function canSave = checkStatus
        % checks the current state of the UI, if it's in valid save state,
        
        canSave = false;
        
        % set error index (1 - empty, 2,3 - invalid path,name, 3 - already exists)
        errInd = zeros(1,1,'uint8'); 
        currErr = '';
        
        % get current text to validate
        currTxt = nameTxt.String; 
        
        % get status of overwriting
        canOvrWrite(1) = ovrWrBut.Value;
        
        %  ----------------------------------------------------------------
        % check if can save, depending on mode
        
        if isempty(currTxt)
            errInd(1) = 1;
        elseif currMode == 1 % saving as file
            
            % split current text into file path and filename (adding ext.)
            [currPath,currName,currExt] = fileparts(currTxt);
            if isempty(currExt), currExt = '.mat'; end
            
            % check if can save
            if ~exist(currPath,'dir')
                errInd(1) = 2; % invalid path
            elseif ~isvarname(currName)
                errInd(1) = 3; % invalid name
            elseif exist(strcat(currName,currExt),'file')
                errInd(1) = 4; % already exists
            end
            
        else % saving as variable
            
            % check if can save
            if ~isvarname(currTxt)
                errInd(1) = 3; % invalid name
            elseif evalin('base',['exist(''',currTxt,''',''var'')'])
                errInd(1) = 4; % already exists
            end
            
        end
        
        %  ----------------------------------------------------------------
        % parse error index
        
        % initialise defaults
        butOpt = {'off','on'};   % button options, 1 for off, 2 for on
        butVal = [2,1,1]; % butOpt ind for warnTxt, ovrwrBut, saveBut
        txtCol = [0.9,0,0];      % color for warning text (red)
        
        switch errInd
            case 1 % is empty
                butVal(1) = 1; % warning text off
            case 2 % invalid path
                currErr = invalPath;
            case 3 % invalid name
                currErr = invalName{currMode};
            case 4 % already exists
                currErr = existsTxt{currMode};
                butVal(2) = 2; % overwrite button on
                if canOvrWrite
                    currErr = strcat(currErr,', will overwrite');
                    txtCol(2) = 0.45; % turns txtCol orange
                    butVal(3) = 2;   % save button on
                    canSave = true;
                end
            otherwise
                % no errors, can save
                butVal(1) = 1; % warning text off
                butVal(3) = 2; % save button on
                canSave = true;
        end
        
        %  ----------------------------------------------------------------
        % update UI based on findings

        % update warning text 
        % (string - any errors, txt color - red/black, visibility - on/off)
        warnTxt.String = currErr;
        warnTxt.ForegroundColor = txtCol;
        warnTxt.Visible = butOpt{butVal(1)};
        
        % update overwrite button (visibility - on/off)
        ovrWrBut.Visible = butOpt{butVal(2)}; 
        
        % if turning overwrite button off, also reset it
        if butVal(2) == 1, ovrWrBut.Value = 0; end
        
        % update save button (enable - on/off)
        saveBut.Enable = butOpt{butVal(3)};
        
        drawnow;
    end

end