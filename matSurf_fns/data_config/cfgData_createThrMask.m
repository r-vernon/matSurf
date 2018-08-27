function [thrMask] = cfgData_createThrMask(data,thrCode,thrVals)
% function to create threshold mask for data
% [called by cfgData_createFig]
%
% (req.) data, data to create mask for
% (req.) thrCode, vector length 3 describing type of thresholding to use
%          - Digit 1: (1) normal,   (2) reverse
%          - Digit 2: (1) absolute, (2) gradient, (3) sigmoidal
%          - Digit 3: (1) single,   (2) double
% (req.) thrVals, values to base threshold upon (e.g. cutoff points)
% (ret.) thrMask, mask ranging 0:1, representing opacity of data point
%        (NOTE: thrMask < 0.01 = 0, thrMask >= 0.99 = 1 regardless)

% convert thrCode into ind
thrInd = sub2ind([2,3,2],thrCode(1),thrCode(2),thrCode(3));

% strip any nans from thrVals (will also make it col. vector)
thrVals = thrVals(~isnan(thrVals));

% make sure thrVals is the right length
switch thrInd
    case {1,2},         numExp = 1; % single/absolute
    case {3,4,5,6,7,8}, numExp = 2; % single gradient/sigmoid, double/absolute
    case {9,10,11,12},  numExp = 4; % double gradient/sigmoid
end
if numel(thrVals) ~= numExp
    error('%d threshold value(s) expected, %d given',numExp,numel(thrVals));
end

%--------------------------------------------------------------------------
% memory saving...

% create persistent variable dataBins, will need to be cleared by
% cfgData_createFig when needs regenerating, but doing this avoids
% potentially costly recalculation step
% (also creating persistant store for thrVals as check, see below)
persistent dataBins;
persistent prev_thrVals;

% some safety checks for dataBins...
% make sure threshold values and number of elements match
% overwriting rather than setting to [] as likely can use same mem. chunk
if isempty(dataBins) || ~isequal(prev_thrVals,thrVals) || numel(data) ~= numel(dataBins)
    can_ovrwr_dataBins = true;
else, can_ovrwr_dataBins = false;
end

% after check, store new thrVals as prev
prev_thrVals = thrVals;

%--------------------------------------------------------------------------
% preliminaries

% if using sigmoidal filter, need midpoint of thrVals (x0, see maths below)
if thrCode(2) == 3
    
    if thrCode(3) == 1
        % if only one sigmoid, can just use mean
        x0 = mean(thrVals);
    else
        % calc. each of the 3 (see case 11) sigmoid midpoints seperately
        x0 = (thrVals(1:3)+thrVals(2:4))/2;
    end
    
else
    
    % if using gradient filter, or double/non-sigmoidal filter, discretize
    % casting to uint8 as at most 6 bins, may be slower but less memory
    if any(thrCode(2:3)==2) && can_ovrwr_dataBins
        
        % by default only left side of bin edges are included, add tiny
        % amount to bin edges so right side included for main bins
        tmp_thrVals = thrVals;
        if numel(thrVals) == 2
            tmp_thrVals(end) = thrVals(end) + eps(thrVals(end));
        else
            tmp_thrVals([2,4]) = thrVals([2,4]) + eps(thrVals([2,4]));
            if tmp_thrVals(2) >= thrVals(3)
                tmp_thrVals(2) = thrVals(3) - eps(thrVals(3)); 
            end
        end
        
        dataBins = uint8(discretize(data,[-inf;tmp_thrVals;inf]));
    end
    
end

% preallocate thrMask if gradient, others create thrMask directly
if thrCode(2)==2
    thrMask = zeros(size(data));
end

%--------------------------------------------------------------------------
% maths behind the sigmoid code...

%{
Formula for logistic (sigmoidal) function: y = (1+exp(-k(x-x0)))^-1
Want y = t when x = b, y = (1-t) when x = a (t = thr. opacity, range 0:1)

[NOTE: log(s/t) = log(s)-log(t)]

First, solve for x0 (should be midpoint of [a,b] as symmetric)

t = (1+exp(-k(b-x0)))^-1 => 1/t = 1+exp(-k(b-x0)) => ...
  (1-t)/t = exp(-k(b-x0)) => log((1-t)/t) = -k(b-x0) [*]

1-t = (1+exp(-k(a-x0)))^-1 => 1/(1-t) = 1+exp(-k(a-x0)) => ...
  t/(1-t) = exp(-k(a-x0)) => log(t/(1-t)) = -k(a-x0)

log(t/(1-t)) = log(t)-log(1-t) = -(log(1-t)-log(t)) = -log((1-t)/t) = ...
  -(-k(b-x0)) = k(b-x0)

Therefore: k(b-x0) = -k(a-x0) => b-x0 = x0-a => x0 = (a+b)/2 (is midpoint!)

Take first result [*]: log((1-t)/t) = -k(b-x0) ... solve for -k

b-x0 = 2b/2 - (a+b)/2 = (2b-a-b)/2 = (b-a)/2

log((1-t)/t) = -k((b-a)/2) => -k = 2/(b-a) * log((1-t)/t)

DONE!

For actual values, want t = 0.99 so y ~ 1 at x = b, and y ~ 0 at x = a
(1-0.99)/0.99 = (100-99)/99 = 1/99

Therefore: x0 = (a+b)/2 ; -k = 2/(b-a) * log(1/99)
%}

%--------------------------------------------------------------------------
% process the data

switch thrInd
    
    case 1 % [1,1,1] - normal absolute single ( _|`` )
        
        % NOTE, line can't plot logicals so uint8 smallest class possible
        thrMask = uint8(data >= thrVals);
        
    case 2 % [2,1,1] - reverse absolute single ( ``|_ )
        
        thrMask = uint8(data <= thrVals);
        
    case 3 % [1,2,1] - normal gradient single ( _/`` )
        
        % calculate y=mx+c for intermediate points
        m = 1/diff(thrVals);
        c = -thrVals(1)*m;
        
        thrMask(dataBins==2) = m*data(dataBins==2) + c;
        thrMask(dataBins==3) = 1;
        
    case 4 % [2,2,1] - reverse gradient single ( ``\_ )
        
        m = -1/diff(thrVals);
        c = -thrVals(2)*m;
        
        thrMask(dataBins==1) = 1;
        thrMask(dataBins==2) = m*data(dataBins==2) + c;
        
    case 5 % [1,3,1] - normal sigmoidal single (smooth _/`` )
        
        % calculate '-k' (slope) then sigmoid for mask
        k = 2/diff(thrVals) * log(1/99);
        thrMask = 1./(1+exp(k*(data-x0)));
        
    case 6 % [2,3,1] - reverse sigmoidal single (smooth ``\_ )
        
        % calculate '-k' (slope) then sigmoid for mask
        k = -2/diff(thrVals) * log(1/99);
        thrMask = 1./(1+exp(k*(data-x0)));
        
    case 7 % [1,1,2] - normal absolute double ( _|``|_ )
        
        thrMask = uint8(dataBins==2);
        
    case 8 % [2,1,2] - reverse absolute double ( ``|_|`` )
        
        thrMask = uint8(dataBins~=2);
        
    case 9 % [1,2,2] - normal gradient double ( _/``\_ )
        
        % calculate y=mx+c for intermediate points
        m = [ 1/diff(thrVals(1:2)); -1/diff(thrVals(3:4)) ];
        c = [ -thrVals(1)*m(1);     -thrVals(4)*m(2)      ];
        
        thrMask(dataBins==2) = m(1)*data(dataBins==2) + c(1);
        thrMask(dataBins==3) = 1;
        thrMask(dataBins==4) = m(2)*data(dataBins==4) + c(2);
        
    case 10 % [2,2,2] - reverse gradient double ( ``\_/`` )
        
        % calculate y=mx+c for intermediate points
        m = [ -1/diff(thrVals(1:2)); 1/diff(thrVals(3:4)) ];
        c = [ -thrVals(2)*m(1);      -thrVals(3)*m(2)     ];
        
        thrMask(dataBins==1 | dataBins==5) = 1;
        thrMask(dataBins==2) = m(1)*data(dataBins==2) + c(1);
        thrMask(dataBins==4) = m(2)*data(dataBins==4) + c(2);
        
    case 11 % [1,3,2] - normal sigmoidal double (smooth _/``\_ )
        
        % NOTE: double sigmoidal masks (cases 11, 12) will need 3 fcns:
        %  - left, right and one to join them
        
        % original code commented out below, actual thrMask calculated in
        % place to try to min. memory usage
        k = 2./(thrVals([2,2,3])-thrVals([1,3,4])) * log(1/99);
        % y1 = 1./(1+exp(k(1)*(data-x0(1))));
        % y2 = 1./(1+exp(k(2)*(data-x0(2))));
        % y3 = 1./(1+exp(k(3)*(data-x0(3))));
        % thrMask = y1.*y2 + (1-y2).*y3;
        thrMask = 1./((1+exp(k(1)*(data-x0(1)))).*(1+exp(k(2)*(data-x0(2))))) + ...
            (1-(1./(1+exp(k(2)*(data-x0(2)))))).*(1./(1+exp(k(3)*(data-x0(3)))));
        
    case 12 % [2,3,2] - reverse sigmoidal double (smooth ``\_/`` )
        
        % thrMask calculated as in case 11
        k = 2./(thrVals([1,2,4])-thrVals([2,3,3])) * log(1/99);
        thrMask = 1./((1+exp(k(1)*(data-x0(1)))).*(1+exp(k(2)*(data-x0(2))))) + ...
            (1-(1./(1+exp(k(2)*(data-x0(2)))))).*(1./(1+exp(k(3)*(data-x0(3)))));
end

%--------------------------------------------------------------------------
% put data on a diet 

if thrCode(2)~=1 % if gradient or sigmoidal filter
    
    % re-bin data to find 1% and 99% opacities
    dataBins = uint8(discretize(data,[-inf; 0.01; 0.99; inf]));
    
    % setting thrMask less than 0.01 to 0, 1% transparancy basically invisible
    % and will reduce memory when cast to sparse (particularly for sigmoids)
    thrMask(dataBins==1) = 0;
    
    % if there's no intermediate points (e.g. sharp enough gradient/sigmoid
    % may mirror absolute filter) recast to uint8 to reduce memory
    if ~any(dataBins==2)
        thrMask = uint8(thrMask);
    end
    
    % just make 99% transparency 1 as effectively opaque anyway
    thrMask(dataBins==3) = 1;
    
end

end


