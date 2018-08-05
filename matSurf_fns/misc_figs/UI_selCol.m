function [selCol] = UI_selCol(rgbCol,winTxt)
% function that allows user to select a colour
%
% (opt.) rgbCol, default rgb colour to start with
% (opt.) winTxt, name for figure at top of window
% (ret.) selCol, the colour the user selected (rgb range 0:1)

selCol = [];

if nargin == 0
    rgbCol = [1,1,1]; % default colour in (r)gb format
    valCol = false;
else
    % validate colour and make sure it lies in range 0:1
    valCol = iscol(rgbCol);
    if ~valCol
        rgbCol = [1,1,1];
    elseif isa(rgbCol,'uint8') || max(rgbCol) > 1
        rgbCol = double(rgbCol)/255;
    end  
end

% if valid colour, return default if user clicks cancel
if valCol, selCol = rgbCol; end

if nargin < 2 || isempty(winTxt) || ~ischar(winTxt)
    winTxt = 'Select color';
end

% convert default colour to (h)sv and he(x)
hDfCol = rgb2hsv(rgbCol);
xDfCol = sprintf('%02X',round(rgbCol*255)); 

%  ========================================================================
%  ---------------------- CREATE COLORWHEEL -------------------------------

% create vertices in terms of theta about colour wheel radius
nTh = 180;                     % (n)umber of (th)eta points
thR = linspace(0,2*pi,nTh+1)'; % (th)eta (r)ange
thR(end) = [];

% create vertices, faces and colour data for (c)olour (w)heel
vCW = [[0; cos(thR)], [0; sin(thR)]];
fCW = [ones(nTh,1), (2:nTh+1)', [3:nTh+1,2]', nan(nTh,1)];
cCW = hsv2rgb([[0; thR/(2*pi)], [0; ones(nTh,1)], ones(nTh+1,1)]);

% add on four extra vertices, one extra face for (v)alue (b)ar
vVB = [1.2, -1; 1.35, -1; 1.35, 1; 1.2, 1];
fVB = nTh+2:nTh+5;
cVB = [repmat(hsv2rgb([hDfCol(1),hDfCol(2),0]),2,1);...
    repmat(hsv2rgb([hDfCol(1),hDfCol(2),1]),2,1)];

% and one last face for the value bar (tri)angle indicator
% (sqrt(3)/20 = 0.1*cos(pi/6),  0.05 = 0.1*sin(pi/6))
vTri = [1.35 + [0;1;1]*sqrt(3)/20,  (hDfCol(3)*2)-1 + [0;-1;1]*0.05];
fTri = [nTh+6:nTh+8,nan];
cTri = zeros(3,3);

%  ========================================================================
%  ---------------------- CREATE COLOR PREVIEW ----------------------------

% (c)olor (p)review will show old and new colors
vCP = [0,0; 60,0; 60,30; 60,60; 0,60; 0,30];
fCP = [1,2,3,6; 6,3,4,5];
cCP = repmat(rgbCol,2,1);

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

delete(findobj('Type','Figure','Tag','selColFig'));

% main figure
% will be modal, so no access to other figures until dealt with
selColFig = figure('WindowStyle','modal',...
    'Name',winTxt,'Tag','selColFig','FileName','selCol.fig',...
    'Units','pixels','Position',[100, 100, 615, 325],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');


% grab context menu for copy/paste
cpMenu = copy_paste_menu;

%  ========================================================================
%  ---------------------- CREATE AXES -------------------------------------

% main colour wheel axis
selColAx = axes(selColFig,'Tag','selColAx',...
    'Units','Pixels','Position',[0,0,360,315],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XLim',[-1.15,1.5],'YLim',[-1.15,1.15],'HitTest','off',...
    'XColor','none','YColor','none','Color','none','NextPlot','add');

% colour wheel preview axis (previous/new colour)
previewAx = axes(selColFig,'Tag','previewAx',...
    'Units','Pixels','Position',[370,50,60,60],...
    'DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual',...
    'XLim',[0,60],'YLim',[0,60],'HitTest','off',...
    'XColor','none','YColor','none','Color','none');

%  ========================================================================
%  ---------------------- CREATE PATCH/LINES ------------------------------

% patch showing colour wheel and value bar
selColPatch = patch(selColAx,'Tag','selColPatch',...
    'faces',[fCW; fVB; fTri],'vertices',[vCW; vVB; vTri],...
    'FaceVertexCData',[cCW; cVB; cTri],'FaceColor','interp',...
    'EdgeColor','none','FaceLighting','none','EdgeLighting','none',...
    'ButtonDownFcn',@selColAx_cBack);

% create solid border around colour wheel and value bar
[~] = line(selColAx,'Tag','selColBord','PickableParts','none',...
    'XData',[vCW([2:end,2],1); nan; vVB([1:end,1],1)],...
    'YData',[vCW([2:end,2],2); nan; vVB([1:end,1],2)],...
    'color','k','LineWidth',1,'LineJoin','miter');

% create dashed lines inside colour wheel
[~] = line(selColAx,'Tag','selColDash','PickableParts','none',...
    'XData',[-1,1, nan, 0,0, nan,-sqrt(2)/2,sqrt(2)/2, nan,-sqrt(2)/2,sqrt(2)/2],...
    'YData',[ 0,0, nan,-1,1, nan,-sqrt(2)/2,sqrt(2)/2, nan,sqrt(2)/2,-sqrt(2)/2],...
    'color','k','LineStyle',':','LineWidth',0.5);

% create marker to show colour
selColMark = line(selColAx,'Tag','selColMark','LineStyle','none',...
    'XData',hDfCol(2)*cos(hDfCol(1)),'YData',hDfCol(2)*sin(hDfCol(1)),...
    'color','k','Marker','o','PickableParts','none');

% create preview patch (previous/new colour)
previewPatch = patch(previewAx,'Tag','previewPatch',...
    'faces',fCP,'vertices',vCP,'FaceVertexCData',cCP,...
    'LineWidth',1,'FaceColor','flat','ButtonDownFcn',@previewPatch_cBack,...
    'EdgeColor','black','FaceLighting','none','EdgeLighting','none');

%  ========================================================================
%  ---------------------- CREATE RGB GROUP --------------------------------

% panel
rgbPan = uipanel(selColFig,'Tag','rgbPan','Title','',...
    'Units','pixels','Position',[370,220,235,90]);

%------------
% text labels

% R text
[~] = uicontrol(rgbPan,'Style','text','String','R',...
    'FontSize',10,'Tag','rTxt','Position',[10 62 20 16]);
% G text
[~] = uicontrol(rgbPan,'Style','text','String','G',...
    'FontSize',10,'Tag','gTxt','Position',[10 37 20 16]);
% B text
[~] = uicontrol(rgbPan,'Style','text','String','B',...
    'FontSize',10,'Tag','bTxt','Position',[10 12 20 16]);

%--------
% sliders

% R slider
rSlide = uicontrol(rgbPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.0196,0.0392],'Value',1,'Tag','rSlide',...
    'Position',[35 62 140 16],'Callback',@rgbSlide_cBack);
% G slider
gSlide = uicontrol(rgbPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.0196,0.0392],'Value',1,'Tag','gSlide',...
    'Position',[35 37 140 16],'Callback',@rgbSlide_cBack);
% B slider
bSlide = uicontrol(rgbPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.0196,0.0392],'Value',1,'Tag','bSlide',...
    'Position',[35 12 140 16],'Callback',@rgbSlide_cBack);

%------------
% edit labels

% R edit
rEdit = uicontrol(rgbPan,'Style','edit','String','255',...
    'FontSize',10,'Tag','rEdit','Position',[180 60 40 20],...
    'Callback',@rgbEdit_cBack,'UIContextMenu',cpMenu);
% G edit
gEdit = uicontrol(rgbPan,'Style','edit','String','255',...
    'FontSize',10,'Tag','gEdit','Position',[180 35 40 20],...
    'Callback',@rgbEdit_cBack,'UIContextMenu',cpMenu);
% B edit
bEdit = uicontrol(rgbPan,'Style','edit','String','255',...
    'FontSize',10,'Tag','bEdit','Position',[180 10 40 20],...
    'Callback',@rgbEdit_cBack,'UIContextMenu',cpMenu);

%  ========================================================================
%  ---------------------- CREATE HSV GROUP --------------------------------

% panel
hsvPan = uipanel(selColFig,'Tag','rgbPan','Title','',...
    'Units','pixels','Position',[370,120,235,90]);

%------------
% text labels

% H text
[~] = uicontrol(hsvPan,'Style','text','String','H',...
    'FontSize',10,'Tag','hTxt','Position',[10 62 20 16]);
% S text
[~] = uicontrol(hsvPan,'Style','text','String','S',...
    'FontSize',10,'Tag','sTxt','Position',[10 37 20 16]);
% V text
[~] = uicontrol(hsvPan,'Style','text','String','V',...
    'FontSize',10,'Tag','vTxt','Position',[10 12 20 16]);

%--------
% sliders

% H slider
hSlide = uicontrol(hsvPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.05,0.1],'Value',0,'Tag','hSlide',...
    'Position',[35 62 140 16],'Callback',@hsvSlide_cBack);
% S slider
sSlide = uicontrol(hsvPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.05,0.1],'Value',0,'Tag','sSlide',...
    'Position',[35 37 140 16],'Callback',@hsvSlide_cBack);
% V slider
vSlide = uicontrol(hsvPan,'Style','slider','Min',0,'Max',1,...
    'SliderStep',[0.05,0.1],'Value',1,'Tag','vSlide',...
    'Position',[35 12 140 16],'Callback',@hsvSlide_cBack);

%------------
% edit labels

% H edit
hEdit = uicontrol(hsvPan,'Style','edit','String','0',...
    'FontSize',10,'Tag','hEdit','Position',[180 60 40 20],...
    'Callback',@hsvEdit_cBack,'UIContextMenu',cpMenu);
% S edit
sEdit = uicontrol(hsvPan,'Style','edit','String','0',...
    'FontSize',10,'Tag','sEdit','Position',[180 35 40 20],...
    'Callback',@hsvEdit_cBack,'UIContextMenu',cpMenu);
% V edit
vEdit = uicontrol(hsvPan,'Style','edit','String','1',...
    'FontSize',10,'Tag','vEdit','Position',[180 10 40 20],...
    'Callback',@hsvEdit_cBack,'UIContextMenu',cpMenu);

%  ========================================================================
%  ---------------------- ADDITIONAL BUTTONS ------------------------------

% new text
[~] = uicontrol(selColFig,'Style','text','String','New',...
    'FontSize',10,'Tag','newTxt','Position',[435 85 40 18],...
    'HorizontalAlignment','left');
% old text
[~] = uicontrol(selColFig,'Style','text','String','Old',...
    'FontSize',10,'Tag','oldTxt','Position',[435 55 40 18],...
    'HorizontalAlignment','left');

% hex text
[~] = uicontrol(selColFig,'Style','text','String','#',...
    'FontSize',10,'Tag','hexTxt','Position',[530 90 10 16]);
% hex edit
hexEdit = uicontrol(selColFig,'Style','edit','String',xDfCol,...
    'FontSize',9,'Tag','hexEdit','Position',[545 90 60 20],...
    'Callback',@hexEdit_cBack,'UIContextMenu',cpMenu);

% preset dropdown
presCol = uicontrol(selColFig,'Style','popupmenu','String',...
    {'Presets','Red','Yellow','Green','Cyan',...
    'Blue','Magenta','White','Black'},...
    'FontSize',10,'Tag','presCol','Position',[370 20 110 20],...
    'Value',1,'Callback',@presCol_cBack);

% cancel button
cancBut = uicontrol(selColFig,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[525,50,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancBut_cBack);

% select button
selBut = uicontrol(selColFig,'Style','pushbutton','String','Select',...
    'Tag','selBut','Position',[525,15,80,25],'BackgroundColor',...
    [46,204,113]/255,'Callback',@selBut_cBack);


%  ========================================================================
%  ---------------------- POINTER MANAGER ---------------------------------

% whenever mouse hovers over text entry, change to ibeam
txtEnterFcn = @(fig, ~) set(fig, 'Pointer', 'ibeam');
iptSetPointerBehavior([rEdit,gEdit,bEdit,hEdit,sEdit,vEdit,hexEdit],...
    txtEnterFcn);

% whenever mouse hovers over button, change to hand
butEnterFcn = @(fig, ~) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([cancBut,selBut,previewPatch],butEnterFcn);

% whenever mouse hovers over colour wheel, change to cross
cwEnterFcn = @(fig, ~) set(fig, 'Pointer', 'cross');
iptSetPointerBehavior(selColPatch,cwEnterFcn);

% create a pointer manager
iptPointerManager(selColFig);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(selColFig,'center');

% make visible
selColFig.Visible = 'on';
drawnow; pause(0.05);

% wait until select
uiwait(selColFig); 

% =========================================================================

%  --------------------------- CALLBACKS ----------------------------------

% =========================================================================

    function selColAx_cBack(~,event)
        % called when click colour wheel or value bar
        
        % get the point clicked
        ip = event.IntersectionPoint;

        if ip(1) > 1.35
            % clicked the triangle marker for value bar
            return;
        end
        
        % get current colour
        newCol = [hSlide.Value,sSlide.Value,vSlide.Value];

        if ip(1) > 1 % clicked value bar
            
            % update value
            newCol(3) = (ip(2)+1)/2; % convert -1:1 to 0:1
            
            % update triangle marker
            selColPatch.Vertices(nTh+6:nTh+8,2) = ip(2) + [0;-1;1]*0.05;
            
        else % clicked colour wheel
            
            % get theta, dealing with -pi:pi to 0:2pi
            th = atan2(ip(2),ip(1));
            if th < 0, th = 2*pi + th; end
            
            % update hue and saturaturation
            newCol(1) = th/(2*pi);
            newCol(2) = hypot(ip(1),ip(2));
            
            % update marker
            selColMark.XData = ip(1);
            selColMark.YData = ip(2);
            
            % update value bar
            selColPatch.FaceVertexCData(nTh+2:nTh+5,:) = [...
                repmat(hsv2rgb([newCol(1),newCol(2),0]),2,1);... 
                repmat(hsv2rgb([newCol(1),newCol(2),1]),2,1)];
            
        end
        updateStatus(newCol,1);
    end

% -------------------------------------------------------------------------

    function rgbSlide_cBack(src,~)
        % callback when RGB slider clicked
        
        % work out which slider changed
        switch src.Tag(1)
            case 'r'
                rEdit.String = num2str(round(src.Value*255));
            case 'g'
                gEdit.String = num2str(round(src.Value*255));
            otherwise
                bEdit.String = num2str(round(src.Value*255));
        end
        newCol = [rSlide.Value,gSlide.Value,bSlide.Value];
        updateStatus(newCol,2);
    end

% -------------------------------------------------------------------------

    function rgbEdit_cBack(src,~)
        % callback when RGB text edited
        
        % make sure it's a valid number
        newNum = str2double(src.String)/255;
        isNum = isrealnum(newNum,0,1);
        
        % work out which text was edited
        switch src.Tag(1)
            case 'r'
                if isNum, rSlide.Value = newNum;
                else
                    src.String = num2str(round(rSlide.Value*255));
                end
            case 'g'
                if isNum, gSlide.Value = newNum;
                else
                    src.String = num2str(round(gSlide.Value*255));
                end
            otherwise
                if isNum, bSlide.Value = newNum;
                else
                    src.String = num2str(round(bSlide.Value*255));
                end
        end
        if isNum
            newCol = [rSlide.Value,gSlide.Value,bSlide.Value];
            updateStatus(newCol,2);
        end
    end

% -------------------------------------------------------------------------

    function hsvSlide_cBack(src,~)
        % callback when HSV slider clicked
        
        % work out which slider changed
        switch src.Tag(1)
            case 'h'
                hEdit.String = sprintf('%.2f',src.Value);
            case 's'
                sEdit.String = sprintf('%.2f',src.Value);
            otherwise
                vEdit.String = sprintf('%.2f',src.Value);
        end
        newCol = [hSlide.Value,sSlide.Value,vSlide.Value];
        updateStatus(newCol,3);
    end

% -------------------------------------------------------------------------

    function hsvEdit_cBack(src,~)
        % callback when HSV text edited
        
        % make sure it's a valid number
        newNum = str2double(src.String);
        isNum = isrealnum(newNum,0,1);
        
        % work out which text was edited
        switch src.Tag(1)
            case 'h'
                if isNum, hSlide.Value = newNum;
                else
                    src.String = sprintf('%.2f',hSlide.Value);
                end
            case 's'
                if isNum, sSlide.Value = newNum;
                else
                    src.String = sprintf('%.2f',sSlide.Value);
                end
            otherwise
                if isNum, vSlide.Value = newNum;
                else
                    src.String = sprintf('%.2f',vSlide.Value);
                end
        end
        if isNum
            newCol = [hSlide.Value,sSlide.Value,vSlide.Value];
            updateStatus(newCol,3);
        end
    end

% -------------------------------------------------------------------------

    function previewPatch_cBack(~,event)
        
        % get the point clicked
        ip = event.IntersectionPoint;
        
        if ip(2) > 30 % clicked top half, swap colours
            previewPatch.FaceVertexCData = ...
                flipud(previewPatch.FaceVertexCData);
            drawnow; pause(0.05);
        else
            newCol = previewPatch.FaceVertexCData(1,:);
            updateStatus(newCol,4);
        end
    end

% -------------------------------------------------------------------------
    
    function hexEdit_cBack(src,~)
        
        % strip any #s in string
        hexStr = erase(src.String,'#');
        
        % check if remaining digits are hexadecimal, and 6 of them
        isHex = all(isstrprop(hexStr,'xdigit')) && length(hexStr) == 6;
        
        % parse it
        if isHex
            src.String = upper(hexStr);
            newCol = hex2dec([hexStr(1:2);hexStr(3:4);hexStr(5:6)])';
            updateStatus(newCol/255,5);
        else
            % replace hex with current string
            rCol = [rSlide.Value,gSlide.Value,bSlide.Value];
            src.String = sprintf('%02X',round(rCol*255)); 
            drawnow; pause(0.05);
        end 
    end

% -------------------------------------------------------------------------

    function presCol_cBack(src,~)
        % called when selecting a preset colour
        
        switch src.Value
            case 1       
                return % Presets
            case 2
                newCol = [1,0,0]; % red
            case 3
                newCol = [1,1,0]; % yellow
            case 4
                newCol = [0,1,0]; % green
            case 5
                newCol = [0,1,1]; % cyan
            case 6
                newCol = [0,0,1]; % blue
            case 7
                newCol = [1,0,1]; % magenta
            case 8
                newCol = [1,1,1]; % white
            case 9
                newCol = [0,0,0]; % black
        end
        
        updateStatus(newCol,6)
    end

% -------------------------------------------------------------------------

    function cancBut_cBack(~,~)
        uiresume(selColFig); 
        delete(selColFig); % just delete figure
    end

% -------------------------------------------------------------------------

    function selBut_cBack(~,~)
        
        % get final selected colour
        selCol = [rSlide.Value,gSlide.Value,bSlide.Value];
        
        uiresume(selColFig); 
        delete(selColFig); % just delete figure
    end

% =========================================================================

%  ---------------------- UPDATE STATUS -----------------------------------

% =========================================================================

    function updateStatus(newCol,colSrc)
        % updates the status of all objects dependent upon source
        % source can be:
        % - 1 - colour wheel
        % - 2 - rgb select
        % - 3 - hsv select
        % - 4 - colour preview (old/new colour)
        % - 5 - hex (will be pre-converted to rgb before passing)
        % - 6 - preset menu
        
        % generate colour in (r)gb and (h)sv, then he(x)
        if  colSrc == 1 || colSrc == 3 % hsv format
            rCol = hsv2rgb(newCol);
            hCol = newCol;
        else                           % rgb format
            rCol = newCol;
            hCol = rgb2hsv(newCol);
        end
        xCol = sprintf('%02X',round(rCol*255)); 
        
        % if source is not colour wheel, update that
        if colSrc ~= 1
            r  = hCol(2);
            th = hCol(1)*2*pi;
            selColMark.XData = r*cos(th);
            selColMark.YData = r*sin(th);
            selColPatch.Vertices(nTh+6:nTh+8,2) = (hCol(3)*2)-1 + [0;-1;1]*0.05;
            selColPatch.FaceVertexCData(nTh+2:nTh+5,:) = [...
                repmat(hsv2rgb([hCol(1),hCol(2),0]),2,1);... 
                repmat(hsv2rgb([hCol(1),hCol(2),1]),2,1)];
        end
        
        % if source is not rgb, update that
        if colSrc ~= 2
            rSlide.Value = rCol(1);
            gSlide.Value = rCol(2);
            bSlide.Value = rCol(3);
            rEdit.String = num2str(round(rCol(1)*255));
            gEdit.String = num2str(round(rCol(2)*255));
            bEdit.String = num2str(round(rCol(3)*255));
        end
        
        % if source is not hsv, update that
        if colSrc ~= 3
            hSlide.Value = hCol(1);
            sSlide.Value = hCol(2);
            vSlide.Value = hCol(3);
            hEdit.String = sprintf('%.2f',hCol(1));
            sEdit.String = sprintf('%.2f',hCol(2));
            vEdit.String = sprintf('%.2f',hCol(3));
        end
        
        % if source is not colour preview, update that
        if colSrc ~= 4
            previewPatch.FaceVertexCData(2,:) = rCol;
        end
        
        % if source is not hex, update that
        if colSrc ~= 5
            hexEdit.String = xCol;
        end
        
        % if source is not preset menu, update that
        if colSrc ~= 6
            presCol.Value = 1;
        end
        
        drawnow; pause(0.05);
    end

end