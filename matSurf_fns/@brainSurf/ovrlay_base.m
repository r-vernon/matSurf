function ovrlay_base(obj,sulcusCol,gyrusCol)
% function to load in base overlay, based upon curvature
%
% (opt.) sulcusCol, color for sulci
% (opt.) gyrusCol, color for gyri
% (set.) obj.baseOvrlay, curvature overlay for surface
% (set.) obj.currOvrlay, sets current overlay to base

%==========================================================================
% parse optional inputs

% set colour defaults for sulcus (luminance 40) and gyrus (luminance 80)
colDef = applycform([40,0,0; 80,0,0],makecform('lab2srgb'));

if nargin < 2 || isempty(sulcusCol)
    sulcusCol = colDef(1,:);
end

if nargin < 3 || isempty(gyrusCol)
    gyrusCol = colDef(2,:);
end

%==========================================================================
% make sure colours are in correct format

% make sure colors are in range 0:1, not 0:255 or -1:+1
sulcusCol = obj.colMap.checkColRange(sulcusCol);
gyrusCol = obj.colMap.checkColRange(gyrusCol);

% make sure sulcus and gyrus colors are RGB *triplets*
if numel(sulcusCol)==1, sulcusCol = repmat(sulcusCol,1,3); end
if numel(gyrusCol)==1, gyrusCol = repmat(gyrusCol,1,3); end

%==========================================================================
% load in curvature information

% corresponding curvature information (casting to single for memory purposes)
try
    curv = read_curv(obj.surfDet.curvPath);
catch ME
    fprintf('Could not load curvature information\n(%s)\n',...
        obj.surfDet.curvPath);
    rethrow(ME);
end

%==========================================================================

% binarise curvature about 0
curveGtrZero = curv > 0;

% create base overlay colors, setting all to gyrus colors for now and
% forcing single for memory purposes
baseCol = repmat(gyrusCol,obj.nVert,1);

% now set sulcus colors for each channel
for rgb = 1:3

    baseCol(curveGtrZero,rgb) = sulcusCol(rgb);

end

%==========================================================================
% save out overlay

% name, data, color, mask
obj.baseOvrlay.name = 'base';
obj.baseOvrlay.data = curv;
obj.baseOvrlay.colData = baseCol;
obj.baseOvrlay.mask = ones(obj.nVert,1);

% also set current overlay as will be base at start
obj.currOvrlay = obj.baseOvrlay;

end