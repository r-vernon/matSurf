function ovrlayInd = ovrlay_find(obj,ovrlay)
% function to return overlay index corresponding to overlay
%
% (req.) ovrlay, name or ind of overlay (e.g. 'ret' or 2), if overlay
%        doesn't exist, returns empty (0 treated as baseOvrlay)
% (ret.) ovrlayInd, index either to requested overlay, 0 for baseOvrlay, or
%        empty if overlay not found

% pre-set ovrlayInd to empty in case error pops up
ovrlayInd = [];

%==========================================================================
% first parse to make sure overlay is sensible...

% if ovrlay given as cell for whatever reason, convert to matrix
if iscell(ovrlay)
    try
        ovrlay = cell2mat(ovrlay);
    catch
        errorMsg;
        return
    end
end

% make sure there's available overlays to get!
if obj.nOvrlays == 0 && (ovrlay ~= 0 || ~strcmpi(obj.baseOvrlay.name,ovrlay))
    warning("No overlays available");
    return
end

%==========================================================================
% now try to find requested overlay

if isnumeric(ovrlay) % if provided as index
    
    % if it's numeric, treat it as an index, should be simple!
    
    % make sure only one index and within usable range
    if ~isscalar(ovrlay) || ovrlay < 0 || ovrlay > obj.nOvrlays
        errorMsg
        return
    else
        % seems to be valid!
        ovrlayInd = ovrlay;
    end
    
    %----------------------------------------------------------------------
    
elseif ischar(ovrlay) % if provided as name
    
    % try to look up the ovrlay...
    
    % search overlay names for requested colormap
    is_ovrlay = strcmpi({obj.dataOvrlay.name},ovrlay);
    
    % if colormap exists, grab the index of the first matching colormap
    if any(is_ovrlay)
        ovrlayInd = find(is_ovrlay,1);
    elseif strcmpi(obj.baseOvrlay.name,ovrlay)
        ovrlayInd = 0;
    else
        % couldn't find it
        errorMsg
        return
    end
    
    %----------------------------------------------------------------------
    
else
    
    % something else was provided as ovrlay...
    errorMsg
    return
    
end

    function errorMsg
        % function just to show details about the overlay if errors occur
        warning("Couldn't find or process overlay");
        disp('Overlay requested was: ');
        whos ovrlay;
        fprintf(["Overlay should be either: \n",...
            "- a name (e.g. 'ret')\n",...
            "- a single number between 0 ('base') and %d\n"],obj.nOvrlays);
    end

end