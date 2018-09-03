function [s] = formatNum(n)
% formats a number as a string, either using scientic (%e) or standard
% notation (%d/%f) dependent upon size

if n ~= 0 && (abs(n) < 1e-3 || abs(n) > 1e5)
    s = sprintf('%.3e',n);
elseif mod(n,1) < eps
    s = sprintf('%d',n);
else
    s = sprintf('%.2f',n);
end

end