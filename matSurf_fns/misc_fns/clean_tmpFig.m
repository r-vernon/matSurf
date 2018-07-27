function clean_tmpFig()
% looks for any temporary figures, closes them if they exist

tmpFig = findobj('Type','Figure','Tag','tmpFig');

if ~isempty(tmpFig)
    delete(tmpFig);
end

end