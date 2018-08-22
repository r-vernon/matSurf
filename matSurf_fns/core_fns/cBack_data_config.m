

% first, just clear any persistent variables in createThrMask to be safe
clear cfgData_createThrMask;

% create figure

%--------------------------------------------------------------------------

% create test data
ovrlayName = 'my overlay';
data = normrnd(0,1,[1e4,1]);

% get val. datapoints
valData = nonzeros(data);

%--------------------------------------------------------------------------

% set the initial values for e.g. 'xth percentile' stats options
% in order: prctile, CI, SD, SEM, trimmean
descrInit.prctile = 95;
descrInit.CI      = 95;
descrInit.SD      = 2;
descrInit.SEM     = 1.96;
descrInit.trMean  = 10;

% get some descriptive stats
descr.mean      = mean(valData); 
descr.SD        = std(valData); 
descr.nnz       = numel(valData);
descr.med       = median(valData);
descr.SEM       = descr.SD/sqrt(descr.nnz);
descr.ptile95   = prctile(valData,[5,95]); % get 5th/95th prctile to use as data range
descr.prctile   = descr.ptile95(2);
descr.CI        = descr.mean + norminv(0.5 + descrInit.CI/200)*descr.SEM;
descr.meanPlSD  = descr.mean + descrInit.SD*descr.SD;
descr.meanPlSEM = descr.mean + descrInit.SEM*descr.SEM;
descr.trMean    = trimmean(valData,descrInit.trMean);

% set min/max
descr.MinMax = [min(valData); max(valData)];
if descr.MinMax(1) > 0 % no neg. vals
    descr.negMinMax = [nan; nan];
    descr.posMinMax = descr.MinMax;
elseif descr.MinMax(2) < 0 % no pos. vals
    descr.negMinMax = descr.MinMax;
    descr.posMinMax = [nan; nan];
else
    descr.negMinMax = [descr.MinMax(1); max(valData(valData < 0))];
    descr.posMinMax = [min(valData(valData > 0)); descr.MinMax(2)];
end

%--------------------------------------------------------------------------
% for now hardcode thresholding for createThrMask

% preallocate thresh code
thrCode = [1,1,1];

% preallocate thrVals (order: a1, b1, a2, b2)
thrVals = nan(4,1);
thrVals(1) = descr.MinMax(1);

%--------------------------------------------------------------------------

% grab a colormap for now
tmpCmap = cmaps;
pCmapName = 'heat';
nCmapName = 'cool';

%---------------------------------
% positive/normal colour map image

posCmap = uint8(tmpCmap.getColVals(linspace(0,1,pCmAx.Position(3)),pCmapName)*255);
posCmap = permute(repmat(posCmap,1,1,pCmAx.Position(4)),[3,1,2]);
pCmap = image(pCmAx,'XData',[0,1],'YData',[0,1],'CData',posCmap,'Tag','pCmap');

%--------------------------
% negative colour map image

negCmap = uint8(tmpCmap.getColVals(linspace(0,1,nCmAx.Position(3)),nCmapName)*255);
negCmap = permute(repmat(negCmap,1,1,nCmAx.Position(4)),[3,1,2]);
nCmap = image(nCmAx,'XData',[0,1],'YData',[0,1],'CData',negCmap,'Tag','nCmap',...
    'AlphaData',0.2);

% =========================================================================

% set value
if thrCode(1) == 1, normFilt.Value = 1;
else, revFilt.Value = 1;
end

% set value
if thrCode(2) == 1, absFilt.Value = 1;
elseif thrCode(2) == 2, gradFilt.Value = 1;
else, sigFilt.Value = 1;
end

% set value
if thrCode(3) == 1, oneFilt.Value = 1;
else, twoFilt.Value = 1;
end

% edit button strings
if ~isnan(thrVals(1)), f1_lEdit.String = sprintf('%.2f',thrVals(1)); end
if ~isnan(thrVals(2)), f1_hEdit.String = sprintf('%.2f',thrVals(2)); end
if ~isnan(thrVals(3)), f2_lEdit.String = sprintf('%.2f',thrVals(3)); end
if ~isnan(thrVals(4)), f2_hEdit.String = sprintf('%.2f',thrVals(4)); end


% calculate XLim (shows 95% of data unless thrVal is lower/higher)
thrXLim = [min([thrVals; descr.ptile95(1)]), max([thrVals; descr.ptile95(2)])];

% calculate xtick and xtick labels
thrXTick = linspace(thrXLim(1),thrXLim(2),6)';
thrXTickLab = num2str(thrXTick,'%.2f');

set(thrAx,'XLim',[thrXLim(1)-0.1,thrXLim(2)+0.1],'XTick',thrXTick,...
    'XTickLabel',thrXTickLab)

% get vals for plot
thrX = linspace(thrXLim(1),thrXLim(2),1e5)';
thrY = cfgData_createThrMask(thrX,thrCode,thrVals);

% set filter line data
if ~isnan(thrVals(1)), set(h.thrFilt_a1,'XData',[thrVals(1),thrVals(1)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(2)), set(h.thrFilt_a2,'XData',[thrVals(2),thrVals(2)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(3)), set(h.thrFilt_b1,'XData',[thrVals(3),thrVals(3)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(4)), set(h.thrFilt_b2,'XData',[thrVals(4),thrVals(4)],'YData',[-0.05,1.05]); end
