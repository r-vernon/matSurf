function [newDescr] = cfgData_setDescrStats(data2Proc,stats_xVal,h,newDescr,stat2update)
% function to update descriptive stats for a data overlay
%
% (req.) data2Proc, data to calculate stats for
% (req.) stats_xVal, x values for custom stats options
% (opt.) h, handle to cfgData figure (if provided, updates core stats text, 
%          or custom stats text if only changing one item)
% (opt.) newDescr, set of current descriptive stats, to be updated
% (opt.) stat2update, if provided, will update single value passing 
%          'allCustom' will update all custom values only

%------------------------------------------------------------
% work out whether to update all stats, or just custom one(s)

if nargin < 4 || isempty(newDescr)
    set_allStd = true;
    set_allCust = true; 
else
    set_allStd = false;
    if strcmp(stat2update,'allCustom')
        set_allCust = true;
    else
        set_allCust = false;
        custToProc = find(strcmp(stat2update,{'prctile','CI','meanPlusSD','meanPlusSEM','trMean'}));
    end
end

%-------------------------------------------
% work out if we should update figure or not

if nargin >= 3 && (set_allStd || ~set_allCust)
    updFig = true;
else
    updFig = false;
end

%-------------------------------------
% deal with standard descriptive stats
if set_allStd
    
    % get median/ptile95 in one go
    med_95prc = prctile(data2Proc,[5,50,95]);
    
    % calculate descriptives with no dependencies
    newDescr = struct(...
        'mean',      mean(data2Proc), ...
        'SD',        std(data2Proc),...
        'nnz',       nnz(data2Proc), ...
        'med',       med_95prc(2), ...
        'ptile95',   med_95prc([1,3]), ...
        'negMinMax', [nan; nan], ...
        'posMinMax', [nan; nan]);
    
    % calculate std. error of mean
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
    
    % (optionally) update fig.
    if updFig
        set(h.meanVal, 'String',formatNum(newDescr.mean),         'UserData',newDescr.mean);
        set(h.sdVal,   'String',formatNum(newDescr.SD),           'UserData',newDescr.SD);
        set(h.pMinVal, 'String',formatNum(newDescr.posMinMax(1)), 'UserData',newDescr.posMinMax(1));
        set(h.pMaxVal, 'String',formatNum(newDescr.posMinMax(2)), 'UserData',newDescr.posMinMax(2));
        set(h.nMaxVal, 'String',formatNum(newDescr.negMinMax(2)), 'UserData',newDescr.negMinMax(2));
        set(h.nMinVal, 'String',formatNum(newDescr.negMinMax(1)), 'UserData',newDescr.negMinMax(1));
    end
end

%-----------------------------------
% deal with custom descriptive stats

if set_allCust 
    
    % update everything
    newDescr.prctile = prctile(data2Proc,stats_xVal.prctile);
    newDescr.CI = newDescr.mean + norminv(0.5 + stats_xVal.CI/200)*newDescr.SEM;
    newDescr.meanPlusSD = newDescr.mean + stats_xVal.meanPlusSD*newDescr.SD;
    newDescr.meanPlusSEM = newDescr.mean + stats_xVal.meanPlusSEM*newDescr.SEM;
    newDescr.trMean = trimmean(data2Proc,stats_xVal.trMean);
    
else
    
    % work out which stat to update
    switch custToProc
        
        case 1 % xth percentile
            newCustSt = prctile(data2Proc,stats_xVal.prctile);
            newDescr.prctile = newCustSt;
            
        case 2 % x% confidence interval
            newCustSt = newDescr.mean + norminv(0.5 + stats_xVal.CI/200)*newDescr.SEM;
            newDescr.CI = newCustSt;
            
        case 3 % mean plus x*SD
            newCustSt = newDescr.mean + stats_xVal.meanPlusSD*newDescr.SD;
            newDescr.meanPlusSD = newCustSt;
            
        case 4 % mean plus x*SEM
            newCustSt = newDescr.mean + stats_xVal.meanPlusSEM*newDescr.SEM;
            newDescr.meanPlusSEM = newCustSt;
            
        case 5 % timmed mean (exclding x%)
            newCustSt = trimmean(data2Proc,stats_xVal.trMean);
            newDescr.trMean = newCustSt;
    end
    
    % (optionally) update fig.
    if updFig
        set(h.othVal, 'String',formatNum(newCustSt), 'UserData',newCustSt);
    end
end

end