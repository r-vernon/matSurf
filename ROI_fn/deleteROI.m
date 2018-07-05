function deleteROI()

% grab global variables
global ROI; % ROI plot

% delete any plotted data
delete(ROI.curr.pl_m); 
delete(ROI.curr.pl_l);

% reset current ROI
ROI.curr(1).pl_m = gobjects;
ROI.curr(1).pl_l = gobjects;
ROI.curr(1).pVert = [];
ROI.curr(1).aVert = {};

end