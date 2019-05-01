function [allVert] = ROI_fill(obj,bPts)
% function to flood fill an ROI contained within specified boundary
% Uses breadth-first based flood filling
%
% (req.) bPts, boundary points, the boundary for the ROI to fill
% (ret.) allVert, all vertices contained within the ROI (incl. boundary)

% create a graph in which all ROI boundary nodes have been deleted
% bin it's connected components ('islands' of nodes)
[bins,binSizes] = conncomp(rmnode(obj.G,bPts));

% test if only one bin - in which case ROI not closed
if numel(binSizes) == 1
    
    % may be e.g. line ROI, just return boundary points  as 'filled' version
    allVert = bPts;
    
else
    
    % create a set of indices to account for deleted nodes
    idx = (1:obj.nVert)';
    idx(bPts) = [];
    
    % find the index of the max bin (this is likely outside ROI)
    [~,maxBin] = max(binSizes);

    % get the indices of all smaller bins
    bins = idx(bins~=maxBin);
    
    % save the final points (adding the boundary points back in)
    allVert = [bPts; bins(:)];
    
end

end