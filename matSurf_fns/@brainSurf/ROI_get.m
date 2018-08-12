function [vCoords] = ROI_get(obj,vertInd)
% function that returns all ROI vertex coordinates for plotting
%
% (opt.) vertInd, additional ROI vertices to add to lineInd
% (ret.) vCoords, Vertex coords corresponding to vertices

% look for any additional vertices if not provided
if nargin < 2
    
    % find ROIs that haven't been finished yet (+1 due to end nan)
    unfinROI = cellfun(@numel,obj.ROIs.allVert) > obj.ROIs.nVert +1;
    
    if any(unfinROI)
        
        % grab the last one, should only ever be one!
        ind = find(unfinROI,1,'last');
        
        % get end index
        allV_end = obj.ROIs.nVert(ind);
        
        % add ROIs vertices to vertInd
        vertInd = [obj.ROIs.allVert{ind}(1:allV_end); nan];
    else
        vertInd = [];
    end
end

%--------------------------------------------------------------------------

% get length of main ROI list 
mLen = numel(obj.ROI_lineInd);

% find NaNs in main ROI list
mNaN = isnan(obj.ROI_lineInd);

% preallocate space for vCoords
vCoords = zeros(mLen + numel(vertInd),3,'single');

% set main vertex coords
vCoords(~mNaN,:) = obj.TR.Points(obj.ROI_lineInd(~mNaN),:);

% put main NaNs in
vCoords(mNaN,:) = nan;

% add on vertInd if any provided
if ~isempty(vertInd)

    % make sure vertInd ends with nan, then check in case additional nans
    if ~isnan(vertInd(end)), vertInd(end+1) = nan; end
    aNaN = isnan(vertInd);

    % convert to actual indices
    aReal = find(~aNaN);
    aNaN  = find(aNaN);

    % set additional vertex coords
    vCoords(mLen + aReal,:) = obj.TR.Points(vertInd(aReal),:);
    
    % put additional NaNs in
    vCoords(mLen + aNaN,:) = nan;

end

end