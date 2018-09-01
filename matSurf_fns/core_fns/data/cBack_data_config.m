function cBack_data_config(~,~)

% clear any persistent variables in createThrMask
clear cfgData_createThrMask;

% create empty figure
h = cfgData_createFig;

% =========================================================================
% load in data

% create test data
ovrlay = create_dummy_data;

% extract data, threshold preferences and vals for more consise code
data = ovrlay.data;
thrPref = ovrlay.thrPref;
thrVals = thrPref.thrVals;

% extract data sig. values if they exist
if ~isempty(ovrlay.dataSig)
    dataSig = ovrlay.dataSig;
    h.sStats.Enable = 'on';
    h.sThr.Enable = 'on';
    % if using sig., turn on 'threshold based on sig. map' option
    if thrPref.useSig, h.sThr.Value = 1; end
else
    dataSig = [];
end

% =========================================================================
% set global opacity

% mask zeros or not
h.maskZeros.Value = thrPref.ignZero;

% set transparancy
h.transSlide.Value = thrPref.transparency;
h.transEdit.String = sprintf('%.2f',thrPref.transparency);

% =========================================================================
% set colormaps

% grab a colormap class for now
cmaps = create_cmaps;

% get colormap names
pCmapName = thrPref.cmapNames{1};
nCmapName = thrPref.cmapNames{2};

% call color panel initialisation fcn.
cfgData_init_colPanel(h,cmaps,thrPref)

% =========================================================================
% set descriptives and initial threshold details

% set (x) defaults for custom stats options (e.g. 'xth percentile')
stats_xVal = struct('prctile',95,'CI',95,'meanPlusSD',2,'meanPlusSEM',1.96,'trMean',10);

% get valid data and set descriptives
if thrPref.ignZero
    valData = data(~any(ovrlay.zeroNanInf,2));
else
    valData = data(~any(ovrlay.zeroNanInf(:,2:3),2));
end
descr = setDescrStats(valData);

% get valid data and set descriptives for sig. if it exists
if ~isempty(dataSig)
    if thrPref.ignZero
        valDataSig = dataSig(~any(ovrlay.zeroNanInf,2));
    else
        valDataSig = dataSig(~any(ovrlay.zeroNanInf(:,2:3),2));
    end
    descrSig = setDescrStats(valDataSig);
end

% set stats in panel (setting UserData to allow copying of exact value)
set(h.meanEdit, 'String',formatNum(descr.mean),         'UserData',descr.mean);
set(h.sdEdit,   'String',formatNum(descr.SD),           'UserData',descr.SD);
set(h.pMinEdit, 'String',formatNum(descr.posMinMax(1)), 'UserData',descr.posMinMax(1));
set(h.pMaxEdit, 'String',formatNum(descr.posMinMax(2)), 'UserData',descr.posMinMax(2));
set(h.nMaxEdit, 'String',formatNum(descr.negMinMax(2)), 'UserData',descr.negMinMax(2));
set(h.nMinEdit, 'String',formatNum(descr.negMinMax(1)), 'UserData',descr.negMinMax(1));
set(h.othEdit,  'String',sprintf('%d',descr.nnz),       'UserData',descr.nnz);

% =========================================================================
% histogram

% create histogram data
if isnan(thrPref.histNBins)
    if ~isempty(dataSig) && thrPref.useSig
        [N,edges] = histcounts(valDataSig);
    else
        [N,edges] = histcounts(valData);
    end
    thrPref.histNBins = numel(N);
else
    if ~isempty(dataSig) && thrPref.useSig
        [N,edges] = histcounts(valDataSig,thrPref.histNBins);
    else
        [N,edges] = histcounts(valData,thrPref.histNBins);
    end
end

% set number of faces (bars) and number of edges
nF = thrPref.histNBins;
nE = 3*nF +1;

% get vertex x/y coords (note: have checked it works if nN is 1 or 2)
% vX goes [e1,e1,e2,e2],[e2,e2,e3,e3],...,[e(n-1),e(n-1),e(n),e(n)]
% vY goes [0,N(1),N(1),0],[0,N(2),N(2),0],...,[0,N(n),N(n),0]
vXY = zeros(nE,2);
vX_ind   = [2:nF; 2:nF; 2:nF];     % [2,2,2],[3,3,3],....
vXY(:,1) = edges([1;1;vX_ind(:);end;end]);
vY_ind1  = (0:3:3*(nF-1)) + [2;3]; % [2,3],[5,6],...
vY_ind2  = [1:nF; 1:nF];           % [1,1],[2,2],...
vXY(vY_ind1(:),2) = N(vY_ind2(:));

% get corresponding face indices (goes [1,2,3,4],[4,5,6,7],...)
vF = (0:3:3*(nF-1))' + (1:4);

% bin the histogram data (1 for normal cmap, 2 for -ve cmap)
histBins = cfgData_binHist(vXY(:,1),thrPref.cmapVals,thrPref.outlierMode);

% set colordata
vCD = ones(nE,3);
vCD(histBins==1,:) = cmaps.getColVals(vXY(histBins==1,1),pCmapName,thrPref.cmapVals(1,:));
if thrPref.numCmaps == 2
    vCD(histBins==2,:) = cmaps.getColVals(vXY(histBins==2,2),nCmapName,thrPref.cmapVals(2,:));
end

% set alphadata
vAD = ones(nE,1);
vAD(isnan(histBins)) = 0;

% plot as bar chart so can change individual colours
set(h.stHist,'Faces',vF,'Vertices',vXY,'FaceVertexCData',vCD,...
    'FaceVertexAlphaData',vAD);

% get line details (goes [1],[2,3],[5,6],...,[end])
lXY_ind = [1; vY_ind1(:); (3*nF)+1];

% clean up indices
clearvars vX_ind vY_ind1 vY_ind2;

% add on line across graph
set(h.stPlot,'XData',vXY(lXY_ind,1),'YData',vXY(lXY_ind,2));

% set or get XLimits
if any(isnan(thrPref.histXLim(1,:)))
    thrPref.histXLim(1,:) = h.statsAx.XLim;
else
    h.statsAx.XLim = thrPref.histXLim(1,:);
end

% set hist. XLim and nBins
set(h.histXLim1Edit,'String',formatNum(h.statsAx.XLim(1)),'UserData',h.statsAx.XLim(1));
set(h.histXLim2Edit,'String',formatNum(h.statsAx.XLim(2)),'UserData',h.statsAx.XLim(2));
set(h.histNBinsEdit,'String',sprintf('%d',thrPref.histNBins));

% =========================================================================
% set the type of thresholding to use

%------------------------------------------------
% set the filter, filter type and # filter values

% set direction (1. normal, 2. reversed)
if thrPref.thrCode(1) == 1, h.normFilt.Value = 1;
else, h.revFilt.Value = 1;
end

% set style (1. absolute, 2. gradient, 3. sigmoidal)
if thrPref.thrCode(2) == 1, h.absFilt.Value = 1;
elseif thrPref.thrCode(2) == 2, h.gradFilt.Value = 1;
else, h.sigFilt.Value = 1;
end

% set number of filters (1 or 2)
if thrPref.thrCode(3) == 1, h.oneFilt.Value = 1;
else, h.twoFilt.Value = 1;
end

%-------------------------
% set the images correctly

h.normFilt.CData = squeeze(h.thrPics(1,thrPref.thrCode(2),thrPref.thrCode(3),:,:,:));
h.revFilt.CData  = squeeze(h.thrPics(2,thrPref.thrCode(2),thrPref.thrCode(3),:,:,:));

%-----------------------------------------------
% set filter threshold ranges ([a1, a2; b1, b2])

if ~isnan(thrVals(1,1))
    set(h.f1_lEdit,'String',formatNum(thrVals(1,1)),'UserData',thrVals(1,1),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f1_lTxt.Enable = 'on';
end
if ~isnan(thrVals(2,1))
    set(h.f1_hEdit,'String',formatNum('%.2f',thrVals(2,1)),'UserData',thrVals(2,1),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f1_hTxt.Enable = 'on';
end
if ~isnan(thrVals(1,2))
    set(h.f2_lEdit,'String',formatNum('%.2f',thrVals(1,2)),'UserData',thrVals(1,2),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f2_lTxt.Enable = 'on';
end
if ~isnan(thrVals(2,2))
    set(h.f2_hEdit,'String',formatNum('%.2f',thrVals(2,2)),'UserData',thrVals(2,2),...
        'Enable','on','UIContextMenu',h.cpMenu); 
    h.f2_hTxt.Enable = 'on';
end

% =========================================================================
% threshold graph

% get the x vals for plot
if ~isempty(dataSig) && thrPref.useSig
    thrX = linspace(descrSig.MinMax(1),descrSig.MinMax(2),1e5)';
else
    thrX = linspace(descr.MinMax(1),descr.MinMax(2),1e5)';
end

% get y vals for plot
thrY = cfgData_createThrMask(thrX,thrPref.thrCode,thrVals(:));
set(h.thrPlot,'XData',thrX,'YData',thrY);

% set or get XLimits
if any(isnan(thrPref.thrXLim))
    thrPref.thrXLim(:) = h.thrAx.XLim;
else
    h.thrAx.XLim = thrPref.thrXLim;
end

% set thr XLim
set(h.thrXLim1Edit,'String',formatNum(h.thrAx.XLim(1)),'UserData',h.thrAx.XLim(1));
set(h.thrXLim2Edit,'String',formatNum(h.thrAx.XLim(2)),'UserData',h.thrAx.XLim(2));    

% set filter line data
if ~isnan(thrVals(1)), set(h.thrFilt_a1,'XData',[thrVals(1),thrVals(1)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(2)), set(h.thrFilt_a2,'XData',[thrVals(2),thrVals(2)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(3)), set(h.thrFilt_b1,'XData',[thrVals(3),thrVals(3)],'YData',[-0.05,1.05]); end
if ~isnan(thrVals(4)), set(h.thrFilt_b2,'XData',[thrVals(4),thrVals(4)],'YData',[-0.05,1.05]); end

% =========================================================================

%  ---------------------- MISC. FUNCTIONS ---------------------------------

% =========================================================================

    function [newDescr] = setDescrStats(data2Proc,newDescr,stat2update)
        % updates descriptive stats for a data overlay
        % optionally pass char stat2update to only update single value
        % passing 'allCustom' will just update all custom values
        % otherwise updates all values
        
        % work out what to update
        if nargin < 3 || isempty(newDescr)
            set_allStd = true;
            custToProc = true(5,1);
        else
            set_allStd = false;
            custToProc = strcmp(stat2update,...
                {'prctile','CI','meanPlusSD','meanPlusSEM','trMean','allCustom'});
        end
        
        %-------------------------------------
        % deal with standard descriptive stats
        if set_allStd
            
            % get median/ptile95 in one go
            tmpDesc = prctile(data2Proc,[5,50,95]);
            
            newDescr = struct('mean', mean(data2Proc), 'SD', std(data2Proc),...
                'nnz', numel(data2Proc), 'med', tmpDesc(2), 'ptile95', tmpDesc([1,3]), ...
                'negMinMax', [nan; nan], 'posMinMax', [nan; nan]);
            newDescr.SEM = newDescr.SD/sqrt(newDescr.nnz);
            
            % set min/max
            newDescr.MinMax = [min(data2Proc); max(data2Proc)];
            if newDescr.MinMax(1) > 0 % no neg. vals
                newDescr.posMinMax = newDescr.MinMax;
            elseif newDescr.MinMax(2) < 0 % no pos. vals
                newDescr.negMinMax = newDescr.MinMax;
            else
                newDescr.negMinMax = [newDescr.MinMax(1); max(data2Proc(data2Proc < 0))];
                newDescr.posMinMax = [min(data2Proc(data2Proc > 0)); newDescr.MinMax(2)];
            end
        end
        
        %-----------------------------------
        % deal with custom descriptive stats
        
        if custToProc(1) || custToProc(6)
            newDescr.prctile = prctile(data2Proc,stats_xVal.prctile);
        end
        if custToProc(2) || custToProc(6)
            newDescr.CI = newDescr.mean + norminv(0.5 + stats_xVal.CI/200)*newDescr.SEM;
        end
        if custToProc(3) || custToProc(6)
            newDescr.meanPlSD = newDescr.mean + stats_xVal.meanPlusSD*newDescr.SD;
        end
        if custToProc(4) || custToProc(6)
            newDescr.meanPlSEM = newDescr.mean + stats_xVal.meanPlusSEM*newDescr.SEM;
        end
        if custToProc(5) || custToProc(6)
            newDescr.trMean = trimmean(data2Proc,stats_xVal.trMean);
        end
        
    end


        
        

end