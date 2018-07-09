function testCall_surface(~,eventdata)

disp('called');

% grab global variables
global fs; % freesurfer surface
global ROI; % ROI plot

% get the closest vertex to the click
clVert_ind = nearestNeighbor(fs.TR,eventdata.IntersectionPoint);
clVert = fs.vert(clVert_ind,:);

% work out path
if isempty(ROI.curr.pVert)
    
    % if first point, plot the data and set plot properties

    ROI.curr.pl_m = patch(clVert(1),clVert(2),clVert(3));
    set(ROI.curr.pl_m,ROI.plotProp(1).NameArray,ROI.plotProp(1).ValueArray);

    % save out closest vertex
    ROI.curr.pVert(1) = clVert_ind;
    ROI.curr.aVert{1} = clVert_ind;
else
    tmpPath = shortestpath(fs.G,ROI.curr.pVert(end),clVert_ind);
    ROI.curr.pVert(end+1) = clVert_ind;
    ROI.curr.aVert{end+1} = tmpPath(2:end);
    
    % grab list of all vertices
    allVert = fs.vert(cell2mat(ROI.curr.aVert),:);

    % update plot

    set(ROI.curr.pl_m,...
        'XData',[ROI.curr.pl_m.XData;fs.vert(tmpPath(2:end),1)],...
        'YData',[ROI.curr.pl_m.YData;fs.vert(tmpPath(2:end),2)],...
        'ZData',[ROI.curr.pl_m.ZData;fs.vert(tmpPath(2:end),3)]);

end
    

% % set it to black
% cm.olayCol = cm.retCol;
% cm.olayCol(closestVert,:) = 0;
% src.FaceVertexCData=cm.olayCol;

fprintf('Pressed button, (%.2f, %.2f, %.2f), Vertex %d\n',...
    eventdata.IntersectionPoint(1),eventdata.IntersectionPoint(2),...
    eventdata.IntersectionPoint(3),clVert_ind);

end