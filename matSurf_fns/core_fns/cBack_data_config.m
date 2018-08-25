function cBack_data_config(~,~)

% first, just clear any persistent variables in createThrMask to be safe...
% ... then load in figure
clear cfgData_createThrMask;
h = cfgData_createFig;

% =========================================================================
% load in data

% create test data
ovrlayName = 'my overlay';
data = normrnd(0,1,[1e4,1]);

% get non-zero datapoints
valData = nonzeros(data);

% =========================================================================
% set descriptives

% set the initial values for e.g. 'xth percentile' stats options...
% ...then set the descriptive stats using those initial values
descrInit = struct('prctile',95,'CI',95,'meanPlusSD',2,'meanPlusSEM',1.96,'trMean',10);
setDescrStats;

%--------------------------------------------------------------------------
% for now hardcode thresholding for createThrMask

% preallocate thresh code
thrCode = [1,1,1];

% preallocate thrVals (order: a1, b1, a2, b2)
thrVals = nan(4,1);
thrVals(1) = descr.MinMax(1);

% =========================================================================
% set colormaps

% grab a colormap for now
cmaps = create_cmaps;
pCmapName = 'heat';
nCmapName = 'cool';

%---------------------------------
% positive/normal colour map image

posCmap = uint8(cmaps.getColVals(linspace(0,1,h.pCmAx.Position(3)),pCmapName)*255);
posCmap = permute(repmat(posCmap,1,1,h.pCmAx.Position(4)),[3,1,2]);
pCmap = image(h.pCmAx,'XData',[0,1],'YData',[0,1],'CData',posCmap,'Tag','pCmap');

%--------------------------
% negative colour map image

negCmap = uint8(cmaps.getColVals(linspace(0,1,h.nCmAx.Position(3)),nCmapName)*255);
negCmap = permute(repmat(negCmap,1,1,h.nCmAx.Position(4)),[3,1,2]);
nCmap = image(h.nCmAx,'XData',[0,1],'YData',[0,1],'CData',negCmap,'Tag','nCmap',...
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

% =========================================================================

%  ---------------------- MISC. FUNCTIONS ---------------------------------

% =========================================================================

    function setDescrStats(stat2update)
        % sets descriptive stats for a data overlay
        % optionally pass char stat2update to only update single value
        % otherwise updates all values

        if nargin == 1 && isfield(descrInit,stat2update)
            
            switch stat2update
                case 'prctile'
                    descr.prctile = prctile(valData,descrInit.prctile);
                case 'CI'
                    descr.CI = descr.mean + norminv(0.5 + descrInit.CI/200)*descr.SEM;
                case 'meanPlusSD'
                    descr.meanPlSD = descr.mean + descrInit.meanPlusSD*descr.SD;
                case 'meanPlusSEM'
                    descr.meanPlSEM = descr.mean + descrInit.meanPlusSEM*descr.SEM;
                case 'trMean'
                    descr.trMean = trimmean(valData,descrInit.trMean);
            end
            
        else
        
            % set standard descriptive stats
            descr = struct('mean', mean(valData), 'SD', std(valData),...
                'nnz', numel(valData), 'med', median(valData), ...
                'ptile95', prctile(valData,[5,95]), ...
                'negMinMax', [nan; nan], 'posMinMax', [nan; nan]);
            descr.SEM = descr.SD/sqrt(descr.nnz);
            
            % add customisable descriptive stats with current settings
            descr.prctile   = prctile(valData,descrInit.prctile);
            descr.CI        = descr.mean + norminv(0.5 + descrInit.CI/200)*descr.SEM;
            descr.meanPlSD  = descr.mean + descrInit.meanPlusSD*descr.SD;
            descr.meanPlSEM = descr.mean + descrInit.meanPlusSEM*descr.SEM;
            descr.trMean    = trimmean(valData,descrInit.trMean);
            
            % set min/max
            descr.MinMax = [min(valData); max(valData)];
            if descr.MinMax(1) > 0 % no neg. vals
                descr.posMinMax = descr.MinMax;
            elseif descr.MinMax(2) < 0 % no pos. vals
                descr.negMinMax = descr.MinMax;
            else
                descr.negMinMax = [descr.MinMax(1); max(valData(valData < 0))];
                descr.posMinMax = [min(valData(valData > 0)); descr.MinMax(2)];
            end
        end
    end

end