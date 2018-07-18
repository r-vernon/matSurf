function dispCurrPoint(src,~)
% function that can be used as a callback to display current point of mouse
% cursor

if ~strcmp(src.Type,'figure') && isprop(src,'CurrentPoint')
    fprintf('Clicked %s object, at:\n',src.Type);
    disp(src.CurrentPoint);
end

% grab figure handle
f_h = getFigHandle(src);
disp('Last clicked figure point was:');
disp(f_h.CurrentPoint);

end