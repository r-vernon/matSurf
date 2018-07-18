function setStatusTxt(txt,errMsg,showWS,padTxt)
% function that updates the status text in a matSurf window (lower right
% text immediately below axis) with 'txt' 
% (if can't set text for any reason, simply returns)
%
% (req.) txt,    text to display as status text (character array)
% (opt.) errMsg, if set to 'w' text will be orange for warning, if set to
%                'e' text will be red for error
% (opt.) showWS, if true, also prints text to workspace
% (opt.) padTxt, by default pads txt so reads '- txt -', can turn off by
%                setting padTxt to false

%--------------------------------------------------------------------------
% parse inputs

% make sure txt is character array (extract from cell first if req.)
if iscell(txt), txt = txt{:}; end
if ~ischar(txt), return; end

% check whether displaying an error message
strCol = [0.35,0.35,0.35];
if nargin >= 2 && ~isempty(errMsg) && ischar(errMsg)
    switch lower(errMsg(1))
        case 'w' % warning
            strCol = [0.9,0.45,0]; % orange
        case 'e' % error 
            strCol = [0.9,0,0];    % red
    end
end

% check whether to show in workspace or not
if nargin < 3 || isempty(showWS) || showWS == 0
    showWS = false;
else
    showWS = true;
end

% check if specified whether to pad or not
if nargin < 4 || isempty(padTxt) || padTxt == 1
    padTxt = true;
else
    padTxt = false;
end

%--------------------------------------------------------------------------
% make sure we can find figure, and status text

% get current figure, and make sure it's a matSurf figure
currFig = get(groot,'CurrentFigure');
if isempty(currFig) || ~strcmp(currFig.Tag,'matSurfFig')
    % try searching for other figures
    currFig = findobj('Type','figure','Tag','matSurfFig');
    if isempty(currFig) || ~strcmp(currFig.Tag,'matSurfFig')
        return
    elseif ~isscalar(currFig)
        % if multiple instances, get the one that was last accessed/created
        [~,latestFig] = max([currFig.UserData]);
        currFig = currFig(latestFig);
    end
end

% find the status text
statTxt = findobj(currFig,'-depth',1,'Tag','statTxt');
if isempty(statTxt), return; end

%--------------------------------------------------------------------------
% set status text

% pad text with '-'s (unless asked not to pad)
if padTxt
    txt = ['- ',txt,' -'];
end

% set the status text
statTxt.String = txt;
statTxt.ForegroundColor = strCol;

% if showing in workspace, print there too
if showWS
    disp(txt);
end

end