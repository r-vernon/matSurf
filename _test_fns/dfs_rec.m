function [vis] = dfs_rec(adjMat,currV,vis)

% note this program works I think but runs out of memory as matlab doesn't
% deal with recursion well...

vis(currV) = currV;
adjV = find(adjMat(:,currV));

for nxtV = 1:numel(adjV)
    if ~vis(adjV(nxtV))
        vis = dfs_rec(adjMat,adjV(nxtV),vis);
    end
end

end