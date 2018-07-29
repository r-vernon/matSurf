function [B] = iscol(A)
% function to test if variable is a valid color
%
% numel == 3 rules out anything that's not [R,G,B]
% for each value, then check if its a real number
% use heurstic to set range either to 0:1, or 1:255
%
% (req.) A, variable to test
% (ret.) B, true if conditions met, false otherwise

% use heuristic to work out if range 0:1, or 1:255
if isrealnum(max(A))
    if isa(A,'uint8') || max(A) > 1
        minA = 1;
        maxA = 255;
    else
        minA = 0;
        maxA = 1;
    end
else
    B = false;
    return
end

% test if colour
B = numel(A) == 3 && isrealnum(A(1),minA,maxA) && ...
    isrealnum(A(2),minA,maxA) && isrealnum(A(3),minA,maxA);

end