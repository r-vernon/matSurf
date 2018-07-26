function [varName] = UI_getVarName(guideTxt,defName)
% function to get a valid variable name
%
% (opt.) guideTxt, what should ask for, e.g. 'enter ROI name'
% (opt.) defName, default name for variable
% (ret.) varName, final variable name

if nargin == 0 || isempty(guideTxt) || ~ischar(guideTxt)
    guideTxt = 'Enter variable name';
end

if nargin < 2 || ~ischar(defName)
    defName = '';
end

% initialise varName
varName = defName;

%--------------------------------------------------------------------------
% create figure

% main figure
% will be modal, so no access to other figures until dealt with
varNameFig = figure('WindowStyle','modal',...
    'Name',guideTxt,'Tag','varNameFig','FileName','varName.fig',...
    'Units','pixels','Position',[100, 100, 320, 95],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% guide text
[~] = uicontrol(varNameFig,'Style','text','String',[guideTxt,':'],'Tag','guideTxt',...
    'HorizontalAlignment','left','Position',[10,70,300,15]);

% text entry
txtEntry = uicontrol(varNameFig,'Style','edit','Tag','txtEntry',...
    'HorizontalAlignment','left','Position',[10,45,300,25],...
    'String',defName,'Callback',@txtEntryCallback);

% reset button
resetBut = uicontrol(varNameFig,'Style','pushbutton','String','reset',...
    'Tag','resetBut','Position',[10,10,50,25],'Callback',@resetCallback);

% clear button
clearBut = uicontrol(varNameFig,'Style','pushbutton','String','clear',...
    'Tag','clearBut','Position',[65,10,50,25],'Callback',@clearCallback);

% okay button
okayBut = uicontrol(varNameFig,'Style','pushbutton','String','Okay',...
    'Tag','okayBut','Position',[230,10,80,25],'Enable','off',...
    'BackgroundColor',[46,204,113]/255,'Callback',@okayCallback);

%--------------------------------------------------------------------------
% create figure

% whenever mouse hovers over text entry, change to ibeam
txtEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'ibeam');
iptSetPointerBehavior(txtEntry, txtEnterFcn);

% whenever text hovers over button, change to hand
butEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([resetBut,clearBut,okayBut],butEnterFcn);

% create a pointer manager
iptPointerManager(varNameFig);

%--------------------------------------------------------------------------
% final setup

% move the window to the center of the screen.
movegui(varNameFig,'center');

% check if variable name has been set
if ~isempty(txtEntry.String)
    [~] = checkStatus;
end

% make visible
varNameFig.Visible = 'on';
drawnow; pause(0.05);

% wait until cancel or load clicked
uiwait(varNameFig);

%--------------------------------------------------------------------------
% callbacks

    function txtEntryCallback(src,~)
        
        if isempty(src.String), return; end
        
        % make sure there's no double quotes
        src.String = char(erase(src.String,{'''','"'}));
        
        % check if it's a valid varName
        [~] = checkStatus;
    end

    function resetCallback(~,~)
        
        txtEntry.String = defName;
        [~] = checkStatus;
            
    end

    function clearCallback(~,~)
        
        txtEntry.String = '';
        txtEntry.ForegroundColor = [0.9,0,0]; % red text
        okayBut.Enable = 'off';
        
    end

    function okayCallback(~,~)
        
        % first just double check status in case clicked before updating
        canSave = checkStatus;
        if ~canSave, return; end
        
        uiresume(varNameFig);
        delete(varNameFig);
    end
        
    function canSave = checkStatus

        % check if text is a valid varName
        if isvarname(txtEntry.String)
            varName = txtEntry.String;
            txtEntry.ForegroundColor = [0,0,0]; % black text
            okayBut.Enable = 'on';
            canSave = true;
        else
            txtEntry.ForegroundColor = [0.9,0,0]; % red text
            okayBut.Enable = 'off';
            canSave = false;
        end
        drawnow; pause(0.05);
    end
end