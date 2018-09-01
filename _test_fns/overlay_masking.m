
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

subplot(1,2,1);

% plot as bar chart so can change individual colours
b = bar(edges,N);
set(b,'BarWidth',1,'FaceColor','flat','cdata',colVals,'LineStyle','none');

% add on spline data
xx = linspace(edges(1),edges(end),1e3);
yy = interp1(edges,N,xx,'spline');
hold on;
p = plot(xx,yy,'k--','LineWidth',1.5);
hold off;

%%-------------------------------------------------------------------------

% create patch alternative
[N,edges] = histcounts(tmpData);
nN = numel(N);

% get vertex x/y coords (note: does still work for nN = 1/2)
% vY goes [e1,e1,e2,e2],[e2,e2,e3,e3],...,[e(n-1),e(n-1),e(n),e(n)]
% vX goes [0,1,1,0],[0,2,2,0],...,[0,n,n,0]
vXY = zeros(3*nN +1,2);
vX_ind   = [2:nN; 2:nN; 2:nN];     % [1,1,1],[2,2,2],....
vXY(:,1) = edges([1;1;vX_ind(:);end;end]);
vY_ind1  = (0:3:3*(nN-1)) + [2;3]; % [2,3],[5,6],...
vY_ind2  = [1:nN; 1:nN];           % [1,1],[2,2],...
vXY(vY_ind1(:),2) = N(vY_ind2(:));


% get corresponding face indices (goes [1,2,3,4],[4,5,6,7],...)
vF = (0:3:3*(nN-1))' + (1:4);

% get color vals
vCD = colmaps.getColVals(vXY(:,1),'heat',[lThresh,uThresh]);
vCD(vXY(:,1) < lThresh,:) = 1;
vCD(vXY(:,1) > uThresh,:) = 1;

% get line details (goes [1],[2,3],[5,6],...,[end])
lXY_ind = [1; vY_ind1(:); (3*nN)+1];

% clean up indices
clearvars vX_ind vY_ind1 vY_ind2;

subplot(1,2,2);
patch('Faces',vF,'Vertices',vXY,'FaceColor','interp','EdgeColor','none',...
    'FaceVertexCData',vCD);
hold on;
line('XData',vXY(lXY_ind,1),'YData',vXY(lXY_ind,2),'LineWidth',1);
hold off;






