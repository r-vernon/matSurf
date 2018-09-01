function [thrPref] = cfgData_plotHist(data2proc,h,cmaps,thrPref,hInd)
% function to create a histogram to represent data
% - actually using patch objects as gives more control over results
%   (and bar graph CData only provided in Matlab 2017+...)
%
% (req.) data2proc, data to create histogram for
% (req.) h, handle to cfgData figure
% (req.) cmaps, handle to colormaps class
% (req.) thrPref, thresholding preferences for data overlay
% (req.) hInd, histogram index, 1 if data, 2 if significance
% (ret.) thrPref, updated thresholding preferences

%---------------------
% check if need to log

if thrPref.useLog(1)
    data2proc = log10(data2proc);
end

%----------------------
% create histogram data

if isnan(thrPref.histNBins(hInd))
    [N,edges] = histcounts(data2proc);   
    thrPref.histNBins(hInd) = numel(N);
else
    [N,edges] = histcounts(data2proc,thrPref.histNBins(hInd));
end

%---------------------
% preallocate stuff...

nF = thrPref.histNBins(hInd); % number of faces (bars)
nE = 3*nF +1;                 % number of edges

hV = zeros(nE,2); % vertices
hCD = ones(nE,3); % color data
hAD = ones(nE,1); % alpha data

% ---------------------
% set vertex x/y coords 

% vX goes [e1,e1,e2,e2],[e2,e2,e3,e3],...,[e(n-1),e(n-1),e(n),e(n)]
vX_ind   = repmat(2:nF,[3,1]); % [2,2,2],[3,3,3],.... (when (:))
hV(:,1) = edges([1;1;vX_ind(:);end;end]);

% vY goes [0,N(1),N(1),0],[0,N(2),N(2),0],...,[0,N(n),N(n),0]
vY_ind1 = (0:3:3*(nF-1)) + [2;3]; % [2,3],[5,6],... (when (:))
vY_ind2 = repmat(1:nF,[2,1]);     % [1,1],[2,2],... (when (:))
hV(vY_ind1(:),2) = N(vY_ind2(:));

% ----------------------------------------
% set faces (goes [1,2,3,4],[4,5,6,7],...)

hF = (0:3:3*(nF-1))' + (1:4);

%-----------------------
% bin the histogram data 
%
% (1 for normal cmap, 2 for -ve cmap)

histBins = cfgData_binHist(hV(:,1),thrPref.cmapVals,thrPref.outlierMode);

%--------------
% set colordata

% first set set positive colormap
hCD(histBins==1,:) = cmaps.getColVals(hV(histBins==1,1),...
    thrPref.cmapNames{1}, thrPref.cmapVals(1,:));

% add second (-ve) colormap if using
if thrPref.numCmaps == 2
    hCD(histBins==2,:) = cmaps.getColVals(hV(histBins==2,1),...
        thrPref.cmapNames{2}, thrPref.cmapVals(2,:));
end

%--------------
% set alphadata

hAD(isnan(histBins)) = 0;

%-------------------------------------------------
% get line coords (goes [1],[2,3],[5,6],...,[end])

lXY_ind = [1; vY_ind1(:); nE];

%--------------------------------------------------------------------------
% plot the results

% set patch objects
set(h.stHist,'Faces',hF,'Vertices',hV,'FaceVertexCData',hCD,...
    'FaceVertexAlphaData',hAD);

% set line
set(h.stPlot,'XData',hV(lXY_ind,1),'YData',hV(lXY_ind,2));

%--------------------------------------------------------------------------
% deal with XLimits

% if XLimits been set previously, use them
if ~any(isnan(thrPref.histXLim(hInd,:)))
    h.statsAx.XLim = thrPref.histXLim(hInd,:);
else
    thrPref.histXLim(hInd,:) = h.statsAx.XLim;
end

% set hist. XLim and nBins edit boxes
set(h.histXLim1Edit,'String',formatNum(h.statsAx.XLim(1)),'UserData',h.statsAx.XLim(1));
set(h.histXLim2Edit,'String',formatNum(h.statsAx.XLim(2)),'UserData',h.statsAx.XLim(2));
set(h.histNBinsEdit,'String',sprintf('%d',thrPref.histNBins(hInd)));

end