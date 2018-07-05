function spTime = shortestPath_timeTest(fs)

mIter = 10;
nIter = 100;

spTime = zeros(mIter,3);

h = waitbar(0,'Processing');

for cIter1 = 1:mIter
    
    s = randi(fs.nVert,1);
    t = randi(fs.nVert,nIter,1);
    
    sPathTree1 = shortestpathtree(fs.G,s,'Method','positive');
    sPathTree2 = shortestpathtree(fs.G,s,'Method','positive','OutputForm','vector');
    
    for cIter2 = 1:nIter
        
%         tic;
%         sPath1 = uint32(shortestpath(fs.G,s,t(cIter2),'Method','positive'));
%         spTime(cIter1,1) = spTime(cIter1,1) + toc;
% 
%         tic;
%         sPath2 = uint32(sPathTree1.shortestpath(s,t(cIter2),'Method','acyclic'));
%         spTime(cIter1,2) = spTime(cIter1,2) + toc;
        
        tic;
        inc = fs.nVert;
        sPath3 = zeros(1,fs.nVert,'uint32');
        sPath3(inc) = t(cIter2);
        while sPathTree2(sPath3(inc))~= 0
            inc = inc - 1;
            sPath3(inc) = sPathTree2(sPath3(inc+1));
        end
        sPath3 = sPath3(inc:end);
        spTime(cIter1,3) = spTime(cIter1,3) + toc;
        
%         if ~all(sPath1 == sPath2) || ~all(sPath1 == sPath3)
%             disp('Not equal');
%         end
    end
    
    waitbar(cIter1/mIter);
    
end

close(h);

spTime = spTime * 1e3;
fprintf('Average T1 was %.02fms (SD %.02f)\n',mean(spTime(:,1)),std(spTime(:,1))); 
fprintf('Average T2 was %.02fms (SD %.02f)\n',mean(spTime(:,2)),std(spTime(:,2)));
fprintf('Average T3 was %.02fms (SD %.02f)\n',mean(spTime(:,3)),std(spTime(:,3)));
