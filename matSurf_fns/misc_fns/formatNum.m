function [s] = formatNum(n)
% formats a number as a string, either using scientic or standard
% notation dependent upon size

if n ~= 0 && (abs(n) < 1e-3 || abs(n) > 1e5)
    s = sprintf('%.3e',n);
else
    s = sprintf('%.2f',n);
end

end