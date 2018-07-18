function [h] = getFigHandle(h)
% returns the figure handle for handle h, e.g. if pass an axis handle in it
% will find the figure containing that axis
%
% (req.) h, handle to graphics object whose figure we want
% (ret.) h, handle to parent figure of graphics object h

if isscalar(h) && ishghandle(h)
    
    % find the handle
    while ~isempty(h) && ~strcmp('figure', h.Type)
        h = h.Parent;
    end
    
    % update timestamp
    h.UserData = now;

else
    warning('Invalid figure handle provided');
    h = [];
end

end