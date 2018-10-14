function cfgData_config_thrPanel(h,thrCode)
% function to configure the thresholding panel, set images correctly and
% enable/disable correct ranges depending upon threshold code
%
% (req.) h, handle to cfgData figure
% (req.) thrCode, threshold code for data overlay
%
% thrCode(1:3) = (n)ormal/(r)everse, (a)bsolute/(g)radient/(s)igmoid, (s)ingle/(d)ouble

%-------------------------
% set the images correctly

h.normFilt.CData = squeeze(h.thrPics(1,thrCode(2),thrCode(3),:,:,:));
h.revFilt.CData  = squeeze(h.thrPics(2,thrCode(2),thrCode(3),:,:,:));

%-----------------------------------------
% work out which filters should be enabled

thrInd = sub2ind([2,3,2],thrCode(1),thrCode(2),thrCode(3));

% lessThan on unless nas (1), nad (7)
% val is 1 when reverse, 0 when normal
if thrInd == 1 || thrInd == 7
    set(h.xLt_txt,'String','? if x <=','Enable','off');
    set(h.xLt_edit,'String','','Enable','off','UserData','','UIContextMenu','');
else
    newTxt = sprintf('%d if x <=',thrCode(1)-1);
    set(h.xLt_txt,'String',newTxt,'Enable','on');
    set(h.xLt_edit,'Enable','on','UIContextMenu',h.cpMenu);
end

% gtrThan on unless ras (2), nad (7)
if thrInd == 2 || thrInd == 7
    set(h.xGt_txt,'String','? if x >=','Enable','off');
    set(h.xGt_edit,'String','','Enable','off','UserData','','UIContextMenu','');
else
    if thrCode(3) ==  1
        % if single, val is 1 when normal, 0 when reverse
        newTxt = sprintf('%d if x >=',2-thrCode(1));
    else
        % if double, val is 1 when reverse, 0 when normal
        newTxt = sprintf('%d if x >=',thrCode(1)-1);
    end
    set(h.xGt_txt,'String',newTxt,'Enable','on');
    set(h.xGt_edit,'Enable','on','UIContextMenu',h.cpMenu);
end

% between off unless double or rad (8)
if thrCode(3) == 1 || thrInd == 8
    h.xBt1_txt.String = '? if';
    set([h.xBt1_txt,h.xBt2_txt],'Enable','off');
    set([h.xBt1_edit,h.xBt2_edit],'String','','Enable','off','UserData','','UIContextMenu','');
else
    h.xBt1_txt.String = sprintf('%d if',2-thrCode(1)); % 1 when normal, 0 when reverse
    set([h.xBt1_txt,h.xBt2_txt],'Enable','on');
    set([h.xBt1_edit,h.xBt2_edit],'Enable','on','UIContextMenu',h.cpMenu);
end

end