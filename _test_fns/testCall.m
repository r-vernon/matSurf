function testCall(~,eventdata)

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
    % marker
    ROI.curr.pl_m = plot3(clVert(1),clVert(2),clVert(3));
    set(ROI.curr.pl_m,ROI.plotProp(1).NameArray,ROI.plotProp(1).ValueArray);
    % line
    ROI.curr.pl_l = plot3(clVert(1),clVert(2),clVert(3));
    set(ROI.curr.pl_l,ROI.plotProp(2).NameArray,ROI.plotProp(2).ValueArray);
    
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
    % marker
    set(ROI.curr.pl_m,'XData',[ROI.curr.pl_m.XData,clVert(1)],...
        'YData',[ROI.curr.pl_m.YData,clVert(2)],...
        'ZData',[ROI.curr.pl_m.ZData,clVert(3)]);
    % line
    set(ROI.curr.pl_l,'XData',allVert(:,1),...
        'YData',allVert(:,2),...
        'ZData',allVert(:,3));
%     set(ROI.curr.pl_l,'XData',[ROI.curr.pl_l.XData,fs.vert(tmpPath(2:end),1)'],...
%         'YData',[ROI.curr.pl_l.YData,fs.vert(tmpPath(2:end),2)'],...
%         'ZData',[ROI.curr.pl_l.ZData,fs.vert(tmpPath(2:end),3)']);

end
    

% % set it to black
% cm.olayCol = cm.retCol;
% cm.olayCol(closestVert,:) = 0;
% src.FaceVertexCData=cm.olayCol;

fprintf('Pressed button, (%.2f, %.2f, %.2f), Vertex %d\n',...
    eventdata.IntersectionPoint(1),eventdata.IntersectionPoint(2),...
    eventdata.IntersectionPoint(3),clVert_ind);

end