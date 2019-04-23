function cBack_data_config(~,~)

% create empty figure
h = cfgData_createFig;
assignin('base','h',h);

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
    iptSetPointerBehavior([h.sStats;h.sThr], '');
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
set(h.othVal, 'String',sprintf('%d',descr.nnz), 'UserData',descr.nnz);

clearvars valInd;

%% ========================================================================
% Thresholding panel

% initialise all the filter values
cfgData_init_thrPanel(h,thrPref.thrCode,thrPref.thrVals)

%% ========================================================================
% Check if using log axis for data or sig

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

% stats other popupmenu
h.othStats.Callback = @cBack_othStats;
h.xEdit.Callback = @cBack_xEdit;

% filter option callbacks
h.normRevFiltBG.SelectionChangedFcn = @cBack_filtChange;
h.typeFiltBG.SelectionChangedFcn = @cBack_filtChange;
h.numFiltBG.SelectionChangedFcn = @cBack_filtChange;

% filter value callbacks
set([h.xLt_edit,h.xGt_edit,h.xBt1_edit,h.xBt2_edit],...
    'Callback',@cBack_filtValEdit);

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
        drawnow;
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
                h.stHist.FaceVertexAlphaData = hAD * newVal;
            end
        else
            src.String = sprintf('%.2f',h.transSlide.Value);
        end
        drawnow;
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
        drawnow;
    end

%% ========================================================================
% stats panel

    function cBack_othStats(src,~)
        
        % get new descr name from userdata
        newDescr = src.UserData{src.Value};
        
        % work out what to do with 'x'
        if src.Value < 4
            % if 1:3, disable x edit option
            h.xTxt.Enable = 'off';
            set(h.xEdit,'String','','UIContextMenu','','Enable','off');
            h.xGuideTxt.Visible = 'off';
        else
            % otherwise, enable and set x edit option
            h.xTxt.Enable = 'on';
            set(h.xEdit,'String',formatNum(stats_xVal.(newDescr)),...
                'UIContextMenu',h.cpMenu,'Enable','on');
            if any(strcmp(newDescr,{'prctile','CI','trMean'}))
                h.xGuideTxt.Visible = 'on';
            else
                h.xGuideTxt.Visible = 'off';
            end
        end
        
        % update text
        if h.dStats.Value == 1
            newVal = descr.(newDescr);
        else
            newVal = descrSig.(newDescr);
        end
        set(h.othVal, 'String',formatNum(newVal), 'UserData',newVal);
        
        drawnow;
    end

    function cBack_xEdit(src,~)
        
        % get current descr name/val from popupmenu userdata
        currDescr = h.othStats.UserData{h.othStats.Value};
        curr_xVal = stats_xVal.(currDescr);
        
        % make sure new xVal is valid
        new_xVal = str2double(src.String);
        if any(strcmp(currDescr,{'prctile','CI','trMean'}))
            isNum = isrealnum(new_xVal,1,99);
        else
            isNum = isrealnum(new_xVal);
        end
        
        % if it's not valid replace with old, otherwise update vals
        if ~isNum
            src.String = formatNum(curr_xVal);
        else
            src.String = formatNum(new_xVal);
            stats_xVal.(currDescr) = new_xVal;
            if h.dStats.Value == 1
                descr = cfgData_setDescrStats(valData,stats_xVal,h,descr,currDescr);
                newVal = descr.(currDescr);
            else
                descrSig = cfgData_setDescrStats(valData,stats_xVal,h,descrSig,currDescr);
                newVal = descrSig.(currDescr);
            end
            set(h.othVal, 'String',formatNum(newVal), 'UserData',newVal);
        end
        
        drawnow;
    end

%% ========================================================================
% threshold panel

    function cBack_filtChange(src,~)
        
        % update relevant threshold preference
        switch src.Tag
            case 'normRevFiltBG'
                thrPref.thrCode(1) = h.normRevFiltBG.SelectedObject.UserData; % normal/reversed
            case 'typeFiltBG'
                thrPref.thrCode(2) = h.typeFiltBG.SelectedObject.UserData;    % filter type
            case 'numFiltBG'
                thrPref.thrCode(3) = h.numFiltBG.SelectedObject.UserData;     % num. filters
                
                % if switching num. filters, 'x>' value to '<=x' location (unless rev. abs. filt)
                if ~(thrPref.thrCode(1) == 2 && thrPref.thrCode(2) == 1)
                    if thrPref.thrCode(3) == 2 % switched to double
                        thrPref.thrVals(2,1) = thrPref.thrVals(1,2);
                        thrPref.thrVals(1,2) = nan;
                        set(h.xGt_edit,'String','','UserData',[]);
                        set(h.xBt1_edit,'String',formatNum(thrPref.thrVals(2,1)),...
                            'UserData',thrPref.thrVals(2,1));
                    else % switched to single
                        thrPref.thrVals(1,2) = thrPref.thrVals(2,1);
                        thrPref.thrVals(2,1) = nan;
                        set(h.xGt_edit,'String',formatNum(thrPref.thrVals(1,2)),...
                            'UserData',thrPref.thrVals(1,2));
                        set(h.xBt1_edit,'String','','UserData',[]);
                    end
                end
        end
        
        % set the images correctly, enable/disable filter value options
        cfgData_config_thrPanel(h,thrPref.thrCode);
        canUpdateThr;
    end

    function cBack_filtValEdit(src,~)
        
        % check for valid strings
        valString = strcmpi(src.String,{'inf','max','-inf','min'});
        if any(valString(1:2))
            if thrPref.useSig
                newVal = descrSig.MinMax(2);
            else
                newVal = descr.MinMax(2);
            end
        elseif any(valString(3:4))
            if thrPref.useSig
                newVal = descrSig.MinMax(1);
            else
                newVal = descr.MinMax(1);
            end
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
                case 'xLt_edit'
                    thrPref.thrVals(1,1) = newVal;
                    if newVal >= thrPref.thrVals(2), h.xBt1_edit.String = ''; end
                    if newVal >= thrPref.thrVals(3), h.xBt2_edit.String = ''; end
                    if newVal >= thrPref.thrVals(4), h.xGt_edit.String = ''; end
                case 'xBt1_edit'
                    thrPref.thrVals(2,1) = newVal;
                    if newVal <= thrPref.thrVals(1), h.xLt_edit.String = ''; end
                    if newVal >= thrPref.thrVals(3), h.xBt2_edit.String = ''; end
                    if newVal >= thrPref.thrVals(4), h.xGt_edit.String = ''; end
                case 'xBt2_edit'
                    thrPref.thrVals(2,2) = newVal;
                    if newVal <= thrPref.thrVals(1), h.xLt_edit.String = ''; end
                    if newVal <= thrPref.thrVals(2), h.xBt1_edit.String = ''; end
                    if newVal >= thrPref.thrVals(3), h.xGt_edit.String = ''; end
                case 'xGt_edit'
                    thrPref.thrVals(1,2) = newVal;
                    if newVal <= thrPref.thrVals(1), h.xLt_edit.String = ''; end
                    if newVal <= thrPref.thrVals(2), h.xBt1_edit.String = ''; end
                    if newVal <= thrPref.thrVals(4), h.xBt2_edit.String = ''; end
            end
            
            % update string
            set(src,'String',formatNum(newVal),'UserData',newVal);
            canUpdateThr;
        end
    end

%% ========================================================================
% additional functions

    function canUpdateThr
        % function to check if can update threshold preview

        canUpdate = true;
        editNames = {'xLt_edit'; 'xBt1_edit'; 'xBt2_edit'; 'xGt_edit'};
        editInd = [1;2;4;3];
        
        for inc = 1:4
            currEdit = editNames{inc};
            
            if strcmpi(h.(currEdit).Enable,'on')
                if any(strcmpi(h.(currEdit).String,{'','nan'}))
                    set(h.(currEdit),'String','','UserData',[]);
                    thrPref.thrVals(editInd(inc)) = nan;
                    canUpdate = false;  
                end
            else
                thrPref.thrVals(editInd(inc)) = nan;
            end
        end
        
        if canUpdate
            h.updateBut.Enable = 'on';
            h.doneBut.Enable = 'on';
        else
            h.updateBut.Enable = 'off';
            h.doneBut.Enable = 'off';
        end
    end

end