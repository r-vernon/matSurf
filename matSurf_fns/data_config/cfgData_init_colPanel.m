function cfgData_init_colPanel(h,cmaps,thrPref)
% function to initialise the colormaps panel
%
% (req.) h, handle to cfgData figure
% (req.) cmaps, handle to colormaps class
% (req.) thrPref, threshold preferences for current data overlay

%-------------------------------------------------------
% extract useful details from thrPref (for cleaner code)

% colormap names
pCmapName = thrPref.cmapNames{1};
nCmapName = thrPref.cmapNames{2};

% colormap values
pCmapVals = thrPref.cmapVals(1,:);
nCmapVals = thrPref.cmapVals(2,:);

%-------------------
% set colormap names

h.cm_pNameText.String = pCmapName;
h.cm_nNameText.String = nCmapName;

%-------------------------
% create colour map images

% set (w)idth and (h)eight of image
im.w = linspace(0,1,h.pCmAx.Position(3));
im.h = h.pCmAx.Position(4);

% get the color vals across image length (converting from 0:1 to 0:255)
posCmap = uint8(cmaps.getColVals(im.w,pCmapName)*255);
negCmap = uint8(cmaps.getColVals(im.w,nCmapName)*255);

% repeat color vals across height, then permute to turn into image
posCmap = permute(repmat(posCmap,1,1,im.h),[3,1,2]);
negCmap = permute(repmat(negCmap,1,1,im.h),[3,1,2]);

% set colordata for image accordingly
h.pCmap.CData = posCmap;
h.nCmap.CData = negCmap;

%----------------------------------
% positive/normal colour map values

set(h.cm_pMinEdit,'String',formatNum(pCmapVals(1)),'UserData',pCmapVals(1));
set(h.cm_pMaxEdit,'String',formatNum(pCmapVals(2)),'UserData',pCmapVals(2));

%----------------------------------
% enable negative colormap if using

if thrPref.numCmaps == 2
    
    h.addNegCM.Value = 1;       % make sure checkbox is ticked
    set(h.nCM,'Enable','on');   % enable all text/edit boxes for -ve cmap
    set(h.nCmap,'AlphaData',1); % change opacity of colormap image
    
    % add values
    set(h.cm_pMinEdit,'String',formatNum(nCmapVals(1)),'UserData',nCmapVals(1));
    set(h.cm_pMaxEdit,'String',formatNum(nCmapVals(2)),'UserData',nCmapVals(2));

    % add context menu
    set([h.cm_pMinEdit,h.cm_pMaxEdit],'UIContextMenu',h.cpMenu);

end

%--------------------------------------------
% set how values outside range are dealt with

if strcmpi(thrPref.outlierMode(1),'m') 
    h.mapCol.Value = 1;  % map
else
    h.clipCol.Value = 1; % clip
end

end