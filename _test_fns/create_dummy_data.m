function [data] = create_dummy_data
% temp function just to create dummy data for overlay threshold testing

% NOTE: no reason to store data where there's zeros, nans or infs as know
% those values zeroNanInf matrix!

% create data, sprinkle in up to 5% nans and infs
dataVals = normrnd(0,1,[1e4,1]);
dataVals(randi(1e4,round((rand(1)/20)*1e4),1)) = nan;
dataVals(randi(1e4,round((rand(1)/20)*1e4),1)) = inf;

data.name = sprintf('overlay %d',randi(99));
data.data = dataVals;
data.dataSig = [];

data.mask    = false(size(dataVals));
data.dataCol = zeros(numel(dataVals),3,'uint8');

% calculate tolerance, will set anything below 0.00001 (1e-5) to zero
% however, if e.g. overlay has very low range this might remove legit vals
% in which case, take val 1e5 times lower than minimum
% absolute lowest thresh is 2e-11/1e5 = 2e-16 (chosen as eps is ~ 2e-16)
absData = abs(dataVals(:));
tol = min([min(absData(absData-0>2e-11))/1e5;1e-5]);

data.zeroNanInf = sparse([absData-0 < tol, isnan(dataVals(:)), isinf(dataVals(:))]);

data.thrPref = cfgData_createThrPref;
data.thrPref.cmapVals(1,1) = min(dataVals(~any(data.zeroNanInf,2)));
data.thrPref.cmapVals(1,2) = max(dataVals(~any(data.zeroNanInf,2)));
data.thrPref.thrVals(1)    = data.thrPref.cmapVals(1,1);

end