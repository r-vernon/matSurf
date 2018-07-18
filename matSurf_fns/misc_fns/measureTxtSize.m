function [txtSize] = measureTxtSize(txt,FontName,FontSize)
% function to meaasure text width and text height in pixels
%
% (req.) txt,      text to measure, either as single character array or
%                  cell of character arrays
% (opt.) FontName, name of font to use
% (opt.) FontSize, font size to use
% (ret.) txtSize,  array with text width and height [w,h] in pixels

% preallocate outputs in case return early
numTxt  = 1;
txtSize = nan(numTxt,2);

%--------------------------------------------------------------------------
% parse inputs

% make sure valid fontname
if nargin < 2 || isempty(FontName)
    FontName = '';
elseif ~ischar(FontName) || ~any(strcmpi(listfonts,FontName))
    warning('Invalid font name, using default');
    FontName = '';
end

% make sure valid fontsize
if nargin < 3 || isempty(FontSize)
    FontSize = '';
elseif ~isnumeric(FontSize) || ~isscalar(FontSize) || FontSize <= 0
    warning('Invalid font size, using default');
    FontSize = '';
end
    
% make sure txt is char, or cell array of chars
if iscell(txt)
    
    % make sure every cell contains char array
    if any(cellfun(@(x) ~ischar(x),txt))
        warning('Text was invalid format - must be char or cell of chars');
        return;
    end
    
    % make sure vector
    if ~isvector(txt)
        txt = txt(:);
    end
    
    % if only one element, extract from cell, else count number to process
    if length(txt) == 1
        txt = txt{1};
    else
        % save number to process and preallocate txtSize with new size
        numTxt = length(txt);
        txtSize = zeros(numTxt,2);
    end

elseif ~ischar(txt)
    
    warning('Text was invalid format - must be char or cell of chars');
    return;
    
end
    
%--------------------------------------------------------------------------
% create user interface elements (both invisible)

% create temporary figure and uicontrol object (hidden)
tmpTxtFig  = figure('Tag','tmpTxtFig','Units','pixels','Visible','off');
strUI = uicontrol(tmpTxtFig,'Style','text','String',' ','Units','pixels',...
    'Tag','strUI','Visible','off');

% set font name and size if using, othrewise save out values used
if ~isempty(FontName), strUI.FontName = FontName; 
else,      FontName =  strUI.FontName; end
if ~isempty(FontSize), strUI.FontSize = FontSize; 
else,       FontSize = strUI.FontSize; end

%--------------------------------------------------------------------------
% get text length

if numTxt == 1
    
    strUI.String = txt;         % set strUI string to text for measuring
    Extent = strUI.Extent;      % get the resulting extent ([0,0,w,h])
    txtSize(1,:) = Extent(3:4); % set width, height
    
else
    for currTxt = 1:numTxt
        
        % as above...
        strUI.String = txt{currTxt};
        Extent = strUI.Extent;
        txtSize(currTxt,:) = Extent(3:4);
        
    end
end

%--------------------------------------------------------------------------

% delete the figure
delete(tmpTxtFig);

% if nargout is 0, and only one entry tested print to terminal
if nargout == 0 && ~iscell(txt)
    if length(txt) >= 10
        fmtTxt = ': \n''%s''\nIs ';
    else
        fmtTxt = ' ''%s'' is ';
    end
    fprintf(['Text',fmtTxt,'%d x %d pixels (H x W; Font: %s, Fontsize: %d)\n'],...
        txt,txtSize(2),txtSize(1),FontName,FontSize);
end

end
    
    
    
    
    
    
    
    