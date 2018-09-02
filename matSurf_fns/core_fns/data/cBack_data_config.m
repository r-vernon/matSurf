function cBack_data_config(~,~)

% create empty figure
h = cfgData_createFig;

%% ========================================================================
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
    if thrPref.useSig
        h.sThr.Value = 1; 
    end
    
else
    dataSig = [];
end

%% ========================================================================
% global opacity panel

% set whether masking zeros or not
h.maskZeros.Value = thrPref.ignZero;

% set transparancy
h.transSlide.Value = thrPref.transparency;
h.transEdit.String = sprintf('%.2f',thrPref.transparency);

%% ========================================================================
% Colormap panel

% grab a colormap class for now
cmaps = create_cmaps;

% call color panel initialisation fcn.
cfgData_init_colPanel(h,cmaps,thrPref)

%% ========================================================================
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

%% ========================================================================
% Thresholding panel

% initialise all the filter values
cfgData_init_thrPanel(h,thrPref.thrCode,thrPref.thrVals)

%% ========================================================================
% Check if using log10

if ~isempty(ovrlay.dataSig)
    thrPref = cfgData_checkLog(h,thrPref,descr.MinMax(1),descrSig.MinMax(1));
else
    thrPref = cfgData_checkLog(h,thrPref,descr.MinMax(1));
end

%% ========================================================================
% Graphs

% set the histogram
if h.dStats.Value == 1
    [thrPref,hAD] = cfgData_plotHist(valData,h,cmaps,thrPref,1);
else
    [thrPref,hAD] = cfgData_plotHist(valDataSig,h,cmaps,thrPref,2);
end

% set threshold graph
if thrPref.useSig
    thrPref = cfgData_plotThr(descrSig.MinMax,h,thrPref);
else
    thrPref = cfgData_plotThr(descr.MinMax,h,thrPref);
end

%% ========================================================================
% figure

% make figure visible
h.confDataFig.Visible = 'on';
drawnow; pause(0.05);

%----------------------------
% let's set some callbacks...

% transparency
h.transSlide.Callback = @cBack_transSlide;
h.transEdit.Callback = @cBack_transEdit;

% colormap value edit
set([h.cm_pMinEdit,h.cm_pMaxEdit,h.cm_nMinEdit,h.cm_nMaxEdit],...
    'Callback',@cBack_cmEdit);

%% ========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================


%% ========================================================================
% global opacity panel

    function cBack_transSlide(src,~)
        % transparency slider
        
        % update edit box
        h.transEdit.String = sprintf('%.2f',src.Value);
        
        % update thrPref, and histogram if in data mode
        thrPref.transparency = src.Value;
        if h.dStats.Value == 1
            h.stHist.FaceVertexAlphaData = hAD * src.Value;
        end
    end

    function cBack_transEdit(src,~)
        
        % make sure it's a valid number
        newVal = str2double(src.String);
        isNum = isrealnum(newVal,0,1);
        
        % if it's a valid number, update slider, thrPref and histogram
        if isNum
            src.String = sprintf('%.2f',newVal); % force formatting
            h.transSlide.Value = newVal;
            thrPref.transparency = newVal;
            if h.dStats.Value == 1
                h.stHist.FaceVertexAlphaData = hAD *newVal;
            end
        else
            src.String = sprintf('%.2f',h.transSlide.Value);
        end
    end

%% ========================================================================
% colormap panel

    function cBack_cmEdit(src,~)
        
        % check for valid strings
        valString = strcmpi(src.String,{'inf','max','-inf','min'});
        if any(valString(1:2))
            newVal = descr.MinMax(2);
        elseif any(valString(3:4))
            newVal = descr.MinMax(1);
        else
            % presume numeric, convert to num
            newVal = str2double(src.String);
        end
        
        % make sure it's a valid number
        isNum = isrealnum(newVal);
        
        if ~isNum
            src.String = formatNum(src.UserData);
        else
            % make sure new value is between lower/upper bounds, then update thrPref
            switch src.Tag
                case 'cm_pMinEdit'
                    lb = h.cm_nMaxEdit.UserData+eps(h.cm_nMaxEdit.UserData);
                    ub = h.cm_pMaxEdit.UserData-eps(h.cm_pMaxEdit.UserData);
                    newVal = max([min([newVal; ub]); lb]);
                    thrPref.cmapVals(1,1) = newVal;
                case 'cm_pMaxEdit'
                    lb = h.cm_pMinEdit.UserData+eps(h.cm_pMinEdit.UserData);
                    newVal = max([newVal; lb]);
                    thrPref.cmapVals(1,2) = newVal;
                case 'cm_nMinEdit'
                    ub = h.cm_nMaxEdit.UserData-eps(h.cm_nMaxEdit.UserData);
                    newVal = min([newVal; ub]);
                    thrPref.cmapVals(2,1) = newVal;
                case 'cm_nMaxEdit'
                    lb = h.cm_nMinEdit.UserData+eps(h.cm_nMinEdit.UserData);
                    ub = h.cm_pMinEdit.UserData-eps(h.cm_pMinEdit.UserData);
                    newVal = min([max([newVal; lb]); ub]);
                    thrPref.cmapVals(2,2) = newVal;
            end
            
            % update string, then histogram
            set(src,'String',formatNum(newVal),'UserData',newVal);
            if h.dStats.Value == 1
                hAD = cfgData_histAlphaColor(h.stHist,cmaps,thrPref,1);
            else
                hAD = cfgData_histAlphaColor(h.stHist,cmaps,thrPref,2);
            end
            
        end
    end

end