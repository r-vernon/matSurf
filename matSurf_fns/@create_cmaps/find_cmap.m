function colInd = find_cmap(obj,cmap)
% function to return color index corresponding to colormap
%
% (req.) cmap, name of colormap (e.g. 'heat'), if cmap doesn't
%        exist, returns default colormap instead
% (ret.) colInd, index either to requested colormap, or index to
%        default colormap


% search colormap names for requested colormap
is_cmap = strcmpi({obj.colMaps.name},cmap);

% if colormap exists, grab the index of the first matching colormap
if any(is_cmap)
    colInd = find(is_cmap,1);
else
    
    % tell user couldn't find the colormap, using default
    fprintf("Could not find '%s' colormap, using default (%s) instead",...
        cmap,obj.def_colMap);
    
    % show list of available colormaps
    list_cmaps(obj);
    
    % set colInd to default colormap, which will always have ind = 1
    colInd = 1; 
    
end


end