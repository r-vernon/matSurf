

data = linspace(0,1,1e6);

mCode = 'dsn'; % (sd, ags, ni)
thrVals  = [0.1,0.475,0.525,0.9];

thrMask = zeros(size(data));

mCode = lower(mCode);
if strcmp(mCode(1),'s') % single filter
    
    if strcmp(mCode(2),'a') % absolute
        
        if strcmp(mCode(3),'n') % normal direction ( _|`` )
            
            thrMask(data > thrVals(1)) = 1;
            
        else % inverted direction ( ``|_ )
            
            thrMask(data < thrVals(1)) = 1;
            
        end
        
    elseif  strcmp(mCode(2),'g') % gradient
        
        % bin the data according to gradient bins
        dataBins = discretize(data,[-inf,thrVals,inf]);
        
        if strcmp(mCode(3),'n') % normal direction ( _/`` )
            
            % calculate y=mx+c for intermediate points
            m = 1/(thrVals(2)-thrVals(1));
            c = -thrVals(1)*m;
        
            thrMask(dataBins==2) = m*data(dataBins==2) + c;
            thrMask(dataBins==3) = 1;
            
        else % inverted direction ( ``\_ )
            
            % calculate y=mx+c for intermediate points
            m = -1/(thrVals(2)-thrVals(1));
            c = -thrVals(2)*m;
            
            thrMask(dataBins==1) = 1;
            thrMask(dataBins==2) = m*data(dataBins==2) + c;
        end
        
    else % sigmoidal
        
        % calculate midpoint
        x0 = mean(thrVals(1:2));
        
        if strcmp(mCode(3),'n') % normal direction (smooth _/`` )
            
            % calculate 'k' (slope) then sigmoid for mask
            k = 2/(thrVals(2)-thrVals(1)) * log(1/99);
            thrMask = 1./(1+exp(k*(data-x0)));
            
        else % inverted direction (smooth ``\_ )
            
            % calculate 'k' (slope) then sigmoid for mask
            k = 2/(thrVals(1)-thrVals(2)) * log(1/99);
            thrMask = 1./(1+exp(k*(data-x0)));
        end
    end
    
else % double filter
 
    if strcmp(mCode(2),'a') % absolute
        
        % bin the data according to bins
        dataBins = discretize(data,[-inf,thrVals,inf]);
    
        if strcmp(mCode(3),'n') % normal shape ( _|``|_ )
            
            thrMask(dataBins==2) = 1;
            
        else % inverted shape ( ``|_|`` )
            
            thrMask(dataBins==1 | dataBins==3) = 1;
            
        end
        
    elseif  strcmp(mCode(2),'g') % gradient
        
        % bin the data according to bins
        dataBins = discretize(data,[-inf,thrVals,inf]);
    
        if strcmp(mCode(3),'n') % normal shape ( _/``\_ )
            
            % calculate y=mx+c for intermediate points
            m(1) = 1/(thrVals(2)-thrVals(1));
            c(1) = -thrVals(1)*m(1);
            m(2) = -1/(thrVals(4)-thrVals(3));
            c(2) = -thrVals(4)*m(2);
            
            thrMask(dataBins==2) = m(1)*data(dataBins==2) + c(1);
            thrMask(dataBins==3) = 1;
            thrMask(dataBins==4) = m(2)*data(dataBins==4) + c(2);
            
        else % inverted shape ( ``\_/`` )
            
            % calculate y=mx+c for intermediate points
            m(1) = -1/(thrVals(2)-thrVals(1));
            c(1) = -thrVals(2)*m(1);
            m(2) = 1/(thrVals(4)-thrVals(3));
            c(2) = -thrVals(3)*m(2);
            
            thrMask(dataBins==1 | dataBins==5) = 1;
            thrMask(dataBins==2) = m(1)*data(dataBins==2) + c(1);
            thrMask(dataBins==4) = m(2)*data(dataBins==4) + c(2);
        end
        
    else % sigmoidal (will need 3 fcns, left, right and one to join them)

        % calculate midpoints
        x0 = (thrVals(1:3)+thrVals(2:4))/2;
        
        if strcmp(mCode(3),'n') % normal shape (smooth _/``\_ )
            
            k = 2./(thrVals([2,2,3])-thrVals([1,3,4])) * log(1/99);
            y1 = 1./(1+exp(k(1)*(data-x0(1))));
            y2 = 1./(1+exp(k(2)*(data-x0(2))));
            y3 = 1./(1+exp(k(3)*(data-x0(3))));
            thrMask = y1.*y2 + (1-y2).*y3;
            
        else % inverted shape (smooth ``\_/`` )
            
            k = 2./(thrVals([1,2,4])-thrVals([2,3,3])) * log(1/99);
            y1 = 1./(1+exp(k(1)*(data-x0(1))));
            y2 = 1./(1+exp(k(2)*(data-x0(2))));
            y3 = 1./(1+exp(k(3)*(data-x0(3))));
            thrMask = y1.*y2 + (1-y2).*y3;
        end
    end
end

h = figure(1);
h.Units = 'pixels';
h.Position = [200,200,70,70];
a = axes(h,'Units','pixels','Position',[10,10,50,50]);
plot(a,data,thrMask,'k','linewidth',2);
axis equal;
axis([-0.5,1.5,-0.5,1.5]);
xticklabels('');
yticklabels('');
xticks([]);
yticks([]);
















