function setStatusTxt(txt,padTxt)
% function that updates the status text in a matSurf window (lower right
% text immediately below axis) with 'txt' 
% (if can't set text for any reason, simply returns)
%
% (req.) txt,    text to display as status text (character array)
% (opt.) padTxt, by default pads txt so reads '- txt -', can turn off by
%                setting padTxt to false

%--------------------------------------------------------------------------
% parse inputs

% make sure txt is character array (extract from cell first if req.)
if iscell(txt), txt = txt{:}; end
if ~ischar(txt), return; end

% check if specified whether to pad or not
if nargin < 2 || isempty(padTxt)
    padTxt = true;
end

%--------------------------------------------------------------------------
% make sure we can find figure, and status text

% get current figure, and make sure it's a matSurf figure
currFig = get(groot,'CurrentFigure');
if isempty(currFig) || ~strcmp(currFig.Tag,'matSurfFig')
    return
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
drawnow;

end