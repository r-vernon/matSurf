function [saveFmt] = UI_saveScreenshot(currSize)
% UI to get save details (resolution/format) etc for screen capture
% 
% (req.) currSize, vector containing size of axis in pixels (1:2) and 
%        pixels/inch (ppi) value of screen (3)

%--------------------------------------------------------------------------
% get data and setup defaults

saveFmt = [];

% set image resolution defaults
ppiDef = {'72','96','150','192','300','600','custom'};
natDef = {'0.5','0.75','1','2','3','4','custom'};

%  ========================================================================
%  ---------------------- CREATE FIGURE -----------------------------------

% main figure
% will be modal, so no access to other figures until dealt with
saveScrShot = figure('WindowStyle','normal',...
    'Name','Save Screenshot','Tag','saveScrShot','FileName','saveScrShot.fig',...
    'Units','pixels','Position',[100, 100, 495, 395],'Visible','off',...
    'NumberTitle','off','MenuBar','none','DockControls','off','Resize','off');

% grab context menu for copy/paste
cpMenu = copy_paste_menu;

%--------------------------------------------------------------------------
% image resolution

% panel
imRes = uibuttongroup(saveScrShot,'Tag','imRes','Title','Base resolution on:',...
    'Units','pixels','Position',[15,185,250,195],...
    'SelectionChangedFcn',@imRes_cBack);

%-----------------------
% pixels per inch option
ppiBut = uicontrol(imRes,'Style','radiobutton','String','pixels/inch (ppi)',...
    'Value',1,'Tag','ppiBut','Position',[10 140 120 25]);

% native option
natBut = uicontrol(imRes,'Style','radiobutton','String','multiple of native',...
    'Tag','natBut','Position',[10 105 150 25]);

%---------------------
% resolution menu text
[~] = uicontrol(imRes,'Style','text','String','preset:','FontSize',9,...
    'HorizontalAlignment','left','FontAngle','italic',...
    'Tag','resMenuTxt','Position',[10 73 60 17]);

% resolution menu
resMenu = uicontrol(imRes,'Style','popupmenu','String',ppiDef,...
    'Value',3,'Tag','resMenu','Position',[10 45 70 25],...
    'Callback',@resMenu_cBack);

%-----------------------
% resolution custom text
[~] = uicontrol(imRes,'Style','text','String','custom:','FontSize',9,...
    'HorizontalAlignment','left','FontAngle','italic',...
    'Tag','resCustTxt','Position',[90 73 70 17]);

% resolution custom
resCust = uicontrol(imRes,'Style','edit','String',ppiDef{3},...
    'Tag','resCust','Position',[90 47 60 23],...
    'Callback',@resCust_cBack,'UIContextMenu',cpMenu);

% resolution text
[~] = uicontrol(imRes,'Style','text','String',...
    sprintf('(Native: %d x %d px, %d ppi)',currSize(1),currSize(2),currSize(3)),...
    'HorizontalAlignment','left','Tag','resText','Position',[10 15 230 20]);

%--------------------------------------------------------------------------
% save format

% panel
imFmt = uibuttongroup(saveScrShot,'Tag','imFmt','Title','Image format:',...
    'Units','pixels','Position',[275,185,205,195],...
    'SelectionChangedFcn',@imFmt_cBack);

%-----------
% jpg option
jpgFmt = uicontrol(imFmt,'Style','radiobutton','String','jpg  (lossy)',...
    'Value',1,'Tag','jpgFmt','Position',[10 140 100 25]);

% quality text
qualTxt = uicontrol(imFmt,'Style','text','String','Quality:',...
    'FontSize',10,'HorizontalAlignment','left','Tag','qualTxt',...
    'Position',[15 110 60 20]);

% quality custom
qualCust = uicontrol(imFmt,'Style','edit','String','85',...
    'FontSize',10,'Tag','qualCust','Position',[70 113 40 20],...
    'Callback',@qualCust_cBack,'UIContextMenu',cpMenu);

% quality menu
qualMenu = uicontrol(imFmt,'Style','popupmenu','String',...
    {'low','med.','high','v. high','custom'},'Value',2,...
    'FontSize',10,'Tag','qualMenu','Position',[120 120 70 15],...
    'Callback',@qualMenu_cBack);

% quality slider
qualSlide = uicontrol(imFmt,'Style','slider','Min',0,'Max',100,...
    'SliderStep',[0.01,0.05],'Value',85,'Tag','qualSlide',...
    'Position',[15 85 175 15],'Callback',@qualSlide_cBack);

%-----------
% png option
pngFmt = uicontrol(imFmt,'Style','radiobutton','String','png  (lossless)',...
    'Tag','pngFmt','Position',[10 50 120 25]);

%-----------
% tif option
tifFmt = uicontrol(imFmt,'Style','radiobutton','String','tif  (lossless)',...
    'Tag','tifFmt','Position',[10 15 120 25]);

%--------------------------------------------------------------------------
% background

% panel
imBack = uibuttongroup(saveScrShot,'Tag','imBack','Title','Background color:',...
    'Units','pixels','Position',[15,70,250,105],...
    'SelectionChangedFcn',@imBack_cBack);

% solid color
solCol = uicontrol(imBack,'Style','radiobutton','String','Solid',...
    'Value',1,'Tag','solCol','Position',[10 50 50 25]);

% background color if solid
bgCol = uicontrol(imBack,'Style','pushbutton','String','',...
    'Tag','bgCol','Position',[70 53 30 20],'CData',ones(10,20,3),...
    'Callback',@bgCol_cBack);

% transparent
noCol = uicontrol(imBack,'Style','radiobutton','String',...
    'Transparent (png only)','Tag','noCol','Position',[10 15 170 25]);

%--------------------------------------------------------------------------
% misc. options

% panel
imOpt = uipanel(saveScrShot,'Tag','imOpt','Title','Misc. Options:',...
    'Units','pixels','Position',[275,70,205,105]);

% show ROIs
showROI = uicontrol(imOpt,'Style','checkbox','String','Show ROIs',...
    'Value',1,'Tag','showROI','Position',[10 50 170 25]);

% crop borders
cropBrd = uicontrol(imOpt,'Style','checkbox','String','Crop empty borders',...
    'Value',0,'Tag','cropBrd','Position',[10 15 170 25]);

%--------------------------------------------------------------------------
% buttons

% preset text
[~] = uicontrol(saveScrShot,'Style','text','String','Presets:','FontSize',9,...
    'HorizontalAlignment','left','FontAngle','italic',...
    'Tag','prstTxt','Position',[18 35 70 20]);

% preset options
presOpt = uicontrol(saveScrShot,'Style','popupmenu',...
    'String',{'Fast (jpg, native)','Default (jpg, 150 ppi)',...
    'H. Quality (png, 300 ppi)'},'Value',2,...
    'Tag','presOpt','Position',[15,15,180,23]);

% preset set button
presBut = uicontrol(saveScrShot,'Style','pushbutton','String','Set',...
    'Tag','presBut','Position',[200,15,40,24],'Callback',@presBut_cBack);

% cancel button
cancBut = uicontrol(saveScrShot,'Style','pushbutton','String','Cancel',...
    'Tag','cancBut','Position',[310,15,80,25],...
    'BackgroundColor',[231,76,60]/255,'Callback',@cancBut_cBack);

% save button
saveBut = uicontrol(saveScrShot,'Style','pushbutton','String','Save',...
    'Tag','saveBut','Position',[400,15,80,25],...
    'BackgroundColor',[1,204,113]/255,'Callback',@saveBut_cBack);

%  ========================================================================
%  ---------------------- POINTER MANAGER ---------------------------------

% whenever mouse hovers over text entry, change to ibeam
txtEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'ibeam');
iptSetPointerBehavior([resCust,qualCust], txtEnterFcn);

% whenever text hovers over button, change to hand
butEnterFcn = @(fig, currentPoint) set(fig, 'Pointer', 'hand');
iptSetPointerBehavior([ppiBut,natBut,resMenu,resCust,jpgFmt,qualMenu,...
    pngFmt,tifFmt,solCol,bgCol,noCol,showROI,cropBrd,...
    presOpt,presBut,cancBut,saveBut],butEnterFcn);

% create a pointer manager
iptPointerManager(saveScrShot);

%  ========================================================================
%  ---------------------- FINAL PROPERTIES --------------------------------

% move the window to the center of the screen.
movegui(saveScrShot,'center');

% make visible
saveScrShot.Visible = 'on';
drawnow; pause(0.05);

% wait until cancel or load clicked
uiwait(saveScrShot);

% =========================================================================

%  ---------------------- CALLBACKS ---------------------------------------

% =========================================================================

% image resolution callbacks

    function imRes_cBack(~,event)
        % call if switch between ppi and multiple of native

        % set resolution menu to defaults dependent upon choice
        if strcmp(event.NewValue.String(1),'p') % ppi
            resMenu.String = ppiDef;
        else                                    % mult. of native
            resMenu.String = natDef;
        end
        
        % either way, set resolution menu to option 3 and update custom
        resMenu.Value  = 3;
        resCust.String = resMenu.String{3};

    end

    function resMenu_cBack(src,~)
        % called if preset changed
        
        % get new value
        newRes = src.String{src.Value};
        
        if ~strcmp(newRes,'custom')
            % update custom field and check if we're in a general preset
            resCust.String = newRes;
        end
    end

    function resCust_cBack(src,~)
        % enteres a custom resolution value
        
        % first check if entered valid number
        if strcmp(imRes.SelectedObject.String(1),'p') % ppi
            src.String = checkValNum(src.String,72,600,1);
        else                                          % mult. of native
            src.String = checkValNum(src.String,0.5,4,0);
        end
        
        % update preset menu dependent upon choice
        isPreset = contains(resMenu.String,src.String);
        if any(isPreset)
            resMenu.Value = find(isPreset);
        else
            resMenu.Value = 7;
        end
    end

%--------------------------------------------------------------------------
% image format callbacks

    function imFmt_cBack(~,event)
        % call if switch between jpg/png/tif
        
        % deal with quality controls
        if strcmp(event.NewValue.String(1:3),'jpg')
            % enable quality controls
            set([qualTxt,qualCust,qualMenu,qualSlide],'Enable','on');
        else
            % disable quality controls
            set([qualTxt,qualCust,qualMenu,qualSlide],'Enable','off');
        end
        
        % if not png, change to solid color
        if ~strcmp(event.NewValue.String(1:3),'png')
            solCol.Value = 1;
        end
    end

    function qualCust_cBack(src,~)
        % entered a custom jpg quality value
        
        % first check if entered valid number
        src.String = checkValNum(src.String,0,100,0);
        
        if isempty(src.String)
            % set defaults
            src.String = '85';
            qualMenu.Value = 2;
            qualSlide.Value = 85;
        else
            qualSlide.Value = str2double(src.String);
            % update preset menu dependent upon choice
            isPreset = contains({'80','85','90','95'},src.String);
            if any(isPreset)
                qualMenu.Value = find(isPreset);
            else
                qualMenu.Value = 5;
            end
        end
    end

    function qualMenu_cBack(src,~)
        % choose a jpg quality preset
        
        if src.Value < 5 % not custom
            
            % map preset text to actual values
            newVal = 80 + (src.Value-1)*5;
            
            % set custom box and slider
            qualCust.String = num2str(newVal);
            qualSlide.Value = newVal;
        end
    end

    function qualSlide_cBack(src,~)
        
        % make sure integer
        src.Value = round(src.Value);
        
        % update custom box
        qualCust.String = num2str(src.Value);
        
        % if new value is a preset, select it
        isPreset = (80:5:95 == src.Value);
        if any(isPreset)
            qualMenu.Value = find(isPreset);
        else
            qualMenu.Value = 5;
        end
    end

%--------------------------------------------------------------------------
% background color callback

    function imBack_cBack(~,event)
        % if setting to transparent, force png
        if strcmp(event.NewValue.String(1),'T')
            pngFmt.Value = 1;
            set([qualTxt,qualCust,qualMenu,qualSlide],'Enable','off');
        end
    end

    function bgCol_cBack(src,~)
        
        % open a colour picker to select new color
        newCol = UI_selCol([1,1,1],'Select background color');
        src.CData = bsxfun(@times,permute(newCol,[1,3,2]),ones(size(src.CData)));
    end

%--------------------------------------------------------------------------
% buttons

    function presBut_cBack(~,~)
        % changes global preset
        
        if presOpt.Value == 3 % if high quality png option
            
            % set fmt to png
            pngFmt.Value = 1;
            
            % disable jpg quality controls
            set([qualTxt,qualCust,qualMenu,qualSlide],'Enable','off');
            
            % set resolution to 300
            resMenu.Value = 5;
            resCust.String = '300';
        else
            
            % will be jpg, so set fmt
            jpgFmt.Value = 1;
            
            % enable jpg quality controls, set to solid background
            set([qualTxt,qualCust,qualMenu,qualSlide],'Enable','on');
            solCol.Value = 1;
            
            % set preset menu to default
            resMenu.Value = 3;
            
            if presOpt.Value == 1 % fast option
                
                % set to native, and change resMenu/custom to 1
                natBut.Value = 1;
                resMenu.String = natDef;
                resCust.String = '1';
                
            elseif presOpt.Value == 2 % default option
                
                % set to ppi, and change resMenu/custom to 150
                ppiBut.Value = 1;
                resMenu.String = ppiDef;
                resCust.String = '150';
                
            end
        end
    end

    function cancBut_cBack(~,~)
        uiresume(saveScrShot);
        delete(saveScrShot); % just delete figure
    end

    function saveBut_cBack(~,~)
        
        % get requested quality value
        res = str2double(resCust.String);
        if ~strcmp(imRes.SelectedObject.String(1),'p') % if not ppi
            res = res*currSize(3);
        end
            
        % fill format structure
        saveFmt = struct(...
            'res',        res,...
            'fmt',        imFmt.SelectedObject.String(1:3),...
            'qual',       qualSlide.Value,...
            'bgStyle',    lower(imBack.SelectedObject.String(1)),...
            'bgCol',      squeeze(bgCol.CData(1,1,:))',...
            'showROIs',   showROI.Value,...
            'cropBorders',cropBrd.Value);
        
        uiresume(saveScrShot);
        delete(saveScrShot); % just delete figure
    end

%--------------------------------------------------------------------------
% function to check if number entered is valid

    function [newNum] = checkValNum(num,numMin,numMax,isInt)
        % checks if num is a valid number, and clips it between min/max
        
        % convert to number
        tmpNum = str2double(num);
        
        % if number should be integer, just round it
        if isInt, tmpNum = round(tmpNum); end
        
        % check if it's usable
        if ~isrealnum(tmpNum)
            newNum = '';
            return;
        elseif tmpNum < numMin
            tmpNum = numMin;
        elseif tmpNum > numMax
            tmpNum = numMax;
        end
        
        % convert back to char
        newNum = num2str(tmpNum);
    end

end
