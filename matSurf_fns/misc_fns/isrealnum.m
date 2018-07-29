function [B] = isrealnum(A,minA,maxA)
% function to test if variable is a single real number
%
% isnumeric rules out all but single, double, int, uint
% isfinite rules out nan, inf
% isscalar rules out numbers with more than 1 element
% is real rules out complex numbers
%
% (req.) A, variable to test
% (opt.) minA, if set, tests if A >= minA
% (opt.) maxA, if set, tests if A <= maxA
% (ret.) B, true if conditions met, false otherwise

% parse inputs
if nargin == 1
    
    % if no range given, just set range to infinite
    rangeA = [-inf,inf];
    
else
    
    % check if min is valid, if not, set to infinite
    if ~isrealnum(minA)
        minA = -inf;
    end
    
    % if max not provided or invalid, set to infinite
    if nargin == 2 || ~isrealnum(maxA)
        maxA = inf;
    end
    
    % make sure min/max in right order
    rangeA = sort([minA,maxA]);
end

% test if real number
B = isnumeric(A) && isfinite(A) && isscalar(A) && isreal(A) && ...
    A >= rangeA(1) && A <= rangeA(2);

end