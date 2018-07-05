function list_cmaps(obj,disp_cmaps)
% function that lists available colormaps
%
% (opt.) disp_cmaps, if true, shows all colormaps in a figure

%--------------------------------------------------------------------------

if nargin < 2 || isempty(disp_cmaps)
    disp_cmaps = false;
end

%--------------------------------------------------------------------------
% list all available colormaps

% grab max length of colormap names and use it for padding
namePadding = cellfun(@length,{obj.colMaps(:).name});
namePadding = max(namePadding) - namePadding;

% print a header
hdrStr = 'Available colormaps:';
fprintf('\n%s\n%s\n\n',hdrStr,repmat('-',1,length(hdrStr)));

% print a new entry with name and description for each colormap
for currCmap = 1:obj.nCmaps
    
    % get amount of padding needed to indent nicely
    padStr = repmat(' ',1,namePadding(currCmap));
    
    % print the string
    fprintf('%d) %s %s- %s\n',...
        currCmap,...
        obj.colMaps(currCmap).name,...
        padStr,...
        obj.colMaps(currCmap).desc);
    
end
disp(' ');

%--------------------------------------------------------------------------
% (optionally) display all available colormaps

if disp_cmaps % if displaying the colormaps as well

    % set xTick and xtick labels (needed so can add spacing before first 0 
    xT = linspace(1,obj.n,6);
    xTLabels = {' 0','0.2','0.4','0.6','0.8','1'};

    % calculate size of figure
    colBarSz = size(obj.colBar);
    figPos = [100,100,2*colBarSz(2),obj.nCmaps*4*colBarSz(1)];
    
    % create temporary figure
    tmpFig = figure('Name','Available Colormaps','Tag','tmpFig',...
        'NumberTitle','off','Visible','off','MenuBar','none',...
        'DockControls','off','Position',figPos);
    
    % plot all colormaps
    for currCmap = 1:obj.nCmaps
        
        % open up a new subplot
        currAx = subplot(obj.nCmaps,1,currCmap);
        
        % show the colorbar with appropriate colormap
        imshow(obj.colBar,[0 1],...
            'Colormap',obj.colMaps(currCmap).cmap,...
            'Parent',currAx);
        
        % set the axis
        set(currAx,'Visible','on',...
            'XTickLabel',xTLabels,...
            'XTick',xT, 'YTick',[],...
            'TickLength',[0,0],...
            'Box','on','LineWidth',1);
        
        % set the label of the figure
        title(obj.colMaps(currCmap).name,'FontWeight','normal');
        
    end
    
    % show the figure
    movegui(tmpFig,'center');
    set(tmpFig,'Visible','on');
    drawnow();
    
end

end