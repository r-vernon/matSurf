function [contextMenu] = copy_paste_menu(allowPaste,allowCopy)
% creates a right click copy/paste context menu
%
% (opt.) allowPaste, if false, hides pasting option
% (opt.) allowCopy, if false, hides copy option
% (ret.) contextMenu, handle to context menu

% make sure flags are valid
if nargin < 1 || ~isrealnum(allowPaste,0,1)
    allowPaste = true; 
end
if nargin < 2 || ~isrealnum(allowCopy,0,1)
    allowCopy = true; 
end

%--------------------------------------------------------------------------

% create context menu
contextMenu = uicontextmenu('Tag','contextMenu');

% create copy menu item
if allowCopy
    [~] = uimenu(contextMenu,'Label','Copy','Tag','copyOpt',...
        'Callback',@copy_cBack);
end

% create paste menu item
if allowPaste
    [~] = uimenu(contextMenu,'Label','Paste','Tag','pasteOpt',...
        'Callback',@paste_cBack);
end

%--------------------------------------------------------------------------
% callbacks

    function copy_cBack(src,~)
        
        % get handle of object that called it
        h = src.Parent.Parent.CurrentObject;
        
        try
            if ~isempty(h.UserData)
                clipboard('copy',h.UserData);
            else
                clipboard('copy',h.String);
            end
        catch
            disp('Could not copy value');
        end
    end

    function paste_cBack(src,~)
        
        % get handle of object that called it
        h = src.Parent.Parent.CurrentObject;
        
        try
            tmpStr = clipboard('paste');
            if ~isempty(tmpStr)
                h.String = tmpStr;
                if ~isempty(h.Callback)
                    h.Callback(h);
                end
            else
                disp('Could not paste value');
            end
        catch
            disp('Could not paste value');
        end
    end

end