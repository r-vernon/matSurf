function cBack_data_config(~,~)

% create empty figure
h = cfgData_createFig;

% =========================================================================
% load in data

% create test data
ovrlay = create_dummy_data;

% extract data and threshold preferences for more concise code
data = ovrlay.data;
thrPref = ovrlay.thrPref;

% extract data sig. values if they exist
if ~isempty(ovrlay.dataSig)
    
    dataSig = ovrlay.dataSig;
    set([h.sStats,h.sThr],'Enable','on');
    
    % if using sig., turn on 'threshold based on sig. map' option
    if thrPref.useSig, h.sThr.Value = 1; end
    
else
    dataSig = [];
end

% =========================================================================
% global opacity panel

% set whether masking zeros or not
h.maskZeros.Value = thrPref.ignZero;

% set transparancy
h.transSlide.Value = thrPref.transparency;
h.transEdit.String = sprintf('%.2f',thrPref.transparency);

% =========================================================================
% Colormap panel

% grab a colormap class for now
cmaps = create_cmaps;

% call color panel initialisation fcn.
cfgData_init_colPanel(h,cmaps,thrPref)

% =========================================================================
% Stats panel

% set (x) defaults for custom stats options (e.g. 'xth percentile')
stats_xVal = struct('prctile',95,'CI',95,'meanPlusSD',2,'meanPlusSEM',1.96,'trMean',10);

% get valid indices
if thrPref.ignZero
    valInd = ~any(ovrlay.zeroNanInf,2);        % remove zeros, nans, infs
else
    valInd = ~any(ovrlay.zeroNanInf(:,2:3),2); % remove nans, infs
end

% get valid data and set descriptives (pass 'h' to update text boxes)
valData = data(valInd);
descr = cfgData_setDescrStats(valData,stats_xVal,h);

% get valid data and set descriptives for sig. if it exists
if ~isempty(dataSig)
    valDataSig = dataSig(valInd);
    descrSig = cfgData_setDescrStats(valDataSig,stats_xVal);
end

% set 'other' option to nnz (setting UserData to allow copying of exact value)
set(h.othEdit, 'String',sprintf('%d',descr.nnz), 'UserData',descr.nnz);

clearvars valInd;

% =========================================================================
% Thresholding panel

% initialise all the filter values
cfgData_init_thrPanel(h,thrPref.thrCode,thrPref.thrVals)

% =========================================================================
% Check if using log10

if ~isempty(ovrlay.dataSig)
    thrPref = cfgData_checkLog(h,thrPref,descr.MinMax(1),descrSig.MinMax(1));
else
    thrPref = cfgData_checkLog(h,thrPref,descr.MinMax(1));
end

% =========================================================================
% Graphs

% set the histogram
if thrPref.useSig
    thrPref = cfgData_plotHist(valDataSig,h,cmaps,thrPref,2);
else
    thrPref = cfgData_plotHist(valData,h,cmaps,thrPref,1);
end

% set threshold graph
if thrPref.useSig
    thrPref = cfgData_plotThr(descrSig.MinMax,h,thrPref);
else
    thrPref = cfgData_plotThr(descr.MinMax,h,thrPref);
end

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================



        
        

end