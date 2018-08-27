
if ~exist('coData','var')
    coData = load('/storage/Matlab_Visualisation/V2/testData.mat');
    coData = coData.coData;
    
    tmpData = coData.data(:);
    tmpData(tmpData == 0) = [];
end

if ~exist('colmaps','var')
    colmaps = create_cmaps;
end

% get some descriptive stats
dStats.n = numel(tmpData);
dStats.mean = mean(tmpData);
dStats.trMean90 = trimmean(tmpData,10);
dStats.median = median(tmpData);
dStats.sd = std(tmpData);
dStats.CI = dStats.mean + [-1.96,1.96]*(dStats.sd/sqrt(dStats.n));
dStats.minmax = [min(tmpData),max(tmpData)];
dStats.range = dStats.minmax(2) - dStats.minmax(1);
dStats.prctile5_95 = prctile(tmpData,[5,95]);

% create histogram data
[N,edges] = histcounts(tmpData);
edges = (edges(1:end-1)+edges(2:end))/2;

% grab colordata
lThresh = 0.2;
uThresh = max(tmpData);
colVals = colmaps.getColVals(edges,'heat',[lThresh,uThresh]);
colVals(edges < lThresh,:) = 1;
colVals(edges > uThresh,:) = 1;

% plot as bar chart so can change individual colours
b = bar(edges,N);
set(b,'BarWidth',1,'FaceColor','flat','cdata',colVals,'LineStyle','none');

% add on spline data
xx = linspace(edges(1),edges(end),1e3);
yy = interp1(edges,N,xx,'spline');
hold on;
p = plot(xx,yy,'k--','LineWidth',1.5);
hold off;
