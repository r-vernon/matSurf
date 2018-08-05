

x = linspace(0,1,1e6);

mCode = 'dsn'; % (sd, ags, ni)
mVal  = [0.1,0.475,0.525,0.9];

mask = zeros(size(x));

mCode = lower(mCode);
if strcmp(mCode(1),'s') % single filter
    
    if strcmp(mCode(2),'a') % absolute
        
        if strcmp(mCode(3),'n') % normal direction ( _|`` )
            
            mask(x > mVal(1)) = 1;
            
        else % inverted direction ( ``|_ )
            
            mask(x < mVal(1)) = 1;
            
        end
        
    elseif  strcmp(mCode(2),'g') % gradient
        
        % bin the data according to gradient bins
        mBins = discretize(x,[-inf,mVal,inf]);
        
        if strcmp(mCode(3),'n') % normal direction ( _/`` )
            
            % calculate y=mx+c for intermediate points
            m = 1/(mVal(2)-mVal(1));
            c = -mVal(1)*m;
        
            mask(mBins==2) = m*x(mBins==2) + c;
            mask(mBins==3) = 1;
            
        else % inverted direction ( ``\_ )
            
            % calculate y=mx+c for intermediate points
            m = -1/(mVal(2)-mVal(1));
            c = -mVal(2)*m;
            
            mask(mBins==1) = 1;
            mask(mBins==2) = m*x(mBins==2) + c;
        end
        
    else % sigmoidal
        
        % calculate midpoint
        x0 = mean(mVal(1:2));
        
        if strcmp(mCode(3),'n') % normal direction (smooth _/`` )
            
            % calculate 'k' (slope) then sigmoid for mask
            k = 2/(mVal(2)-mVal(1)) * log(1/99);
            mask = 1./(1+exp(k*(x-x0)));
            
        else % inverted direction (smooth ``\_ )
            
            % calculate 'k' (slope) then sigmoid for mask
            k = 2/(mVal(1)-mVal(2)) * log(1/99);
            mask = 1./(1+exp(k*(x-x0)));
        end
    end
    
else % double filter
 
    if strcmp(mCode(2),'a') % absolute
        
        % bin the data according to bins
        mBins = discretize(x,[-inf,mVal,inf]);
    
        if strcmp(mCode(3),'n') % normal shape ( _|``|_ )
            
            mask(mBins==2) = 1;
            
        else % inverted shape ( ``|_|`` )
            
            mask(mBins==1 | mBins==3) = 1;
            
        end
        
    elseif  strcmp(mCode(2),'g') % gradient
        
        % bin the data according to bins
        mBins = discretize(x,[-inf,mVal,inf]);
    
        if strcmp(mCode(3),'n') % normal shape ( _/``\_ )
            
            % calculate y=mx+c for intermediate points
            m(1) = 1/(mVal(2)-mVal(1));
            c(1) = -mVal(1)*m(1);
            m(2) = -1/(mVal(4)-mVal(3));
            c(2) = -mVal(4)*m(2);
            
            mask(mBins==2) = m(1)*x(mBins==2) + c(1);
            mask(mBins==3) = 1;
            mask(mBins==4) = m(2)*x(mBins==4) + c(2);
            
        else % inverted shape ( ``\_/`` )
            
            % calculate y=mx+c for intermediate points
            m(1) = -1/(mVal(2)-mVal(1));
            c(1) = -mVal(2)*m(1);
            m(2) = 1/(mVal(4)-mVal(3));
            c(2) = -mVal(3)*m(2);
            
            mask(mBins==1 | mBins==5) = 1;
            mask(mBins==2) = m(1)*x(mBins==2) + c(1);
            mask(mBins==4) = m(2)*x(mBins==4) + c(2);
        end
        
    else % sigmoidal (will need 3 fcns, left, right and one to join them)

        % calculate midpoints
        x0 = (mVal(1:3)+mVal(2:4))/2;
        
        if strcmp(mCode(3),'n') % normal shape (smooth _/``\_ )
            
            k = 2./(mVal([2,2,3])-mVal([1,3,4])) * log(1/99);
            y1 = 1./(1+exp(k(1)*(x-x0(1))));
            y2 = 1./(1+exp(k(2)*(x-x0(2))));
            y3 = 1./(1+exp(k(3)*(x-x0(3))));
            mask = y1.*y2 + (1-y2).*y3;
            
        else % inverted shape (smooth ``\_/`` )
            
            k = 2./(mVal([1,2,4])-mVal([2,3,3])) * log(1/99);
            y1 = 1./(1+exp(k(1)*(x-x0(1))));
            y2 = 1./(1+exp(k(2)*(x-x0(2))));
            y3 = 1./(1+exp(k(3)*(x-x0(3))));
            mask = y1.*y2 + (1-y2).*y3;
        end
    end
end

h = figure(1);
h.Units = 'pixels';
h.Position = [200,200,70,70];
a = axes(h,'Units','pixels','Position',[10,10,50,50]);
plot(a,x,mask,'k','linewidth',2);
axis equal;
axis([-0.5,1.5,-0.5,1.5]);
xticklabels('');
yticklabels('');
xticks([]);
yticks([]);
















