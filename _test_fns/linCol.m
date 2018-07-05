
m1 = 1e5;
m2 = 300;

% create colormap
% a1 = hot(m1); % black body heat
% a1 = hot(m1); a1(:,[1,3]) = a1(:,[3,1]); % % black body cool
% a1 = [ones(m1,1),linspace(0,1,m1)',zeros(m1,1)]; % red to yellow
% a1 = [zeros(m1,1),linspace(0,1,m1)',ones(m1,1)]; % blue to lightblue
a1 = jet(m1); % hsv

a2  = interp1(linspace(0,1,m1),a1,linspace(0,1,m2));

b = rgb2lab(a1);
c = interp1(b(:,1),linspace(0,1,m1), linspace(min(b(:,1)),max(b(:,1)),m2));
d = interp1(linspace(0,1,m1),b,c,'linear');
e = round(lab2rgb(d)*255)/255;
f = rgb2lab(e);

nPoints = 8;
g = interp1(linspace(0,1,m1),b(:,2:3),linspace(0,1,nPoints));
h = zeros(m2,3);
% h(:,1) = linspace(min(b(:,1)),max(b(:,1)),m2);
h(:,1) = repmat(70,m2,1);
h(:,2:3) = interp1(linspace(0,1,nPoints),g,linspace(0,1,m2),'spline');
i = round(lab2rgb(h)*255)/255;

figure(1);
subplot(1,3,1); plot(b(:,1));
subplot(1,3,2); plot(f(:,1));
subplot(1,3,3); plot(h(:,1));

figure(2);
subplot(1,3,1); plot(b(:,2:3));
subplot(1,3,2); plot(f(:,2:3));
subplot(1,3,3); plot(h(:,2:3));

imSize = round(m2*(1/3));
f1 = zeros(m2,imSize,3);
f2 = zeros(m2,imSize,3);
f3 = zeros(m2,imSize,3);
for inc = 1:3
    f1(:,:,inc) = repmat(a2(:,inc),1,imSize);
    f2(:,:,inc) = repmat(e(:,inc),1,imSize);
    f3(:,:,inc) = repmat(i(:,inc),1,imSize);
end

figure(3);
subplot(1,3,1); imshow(f1,[0 1]);
subplot(1,3,2); imshow(f2,[0 1]);
subplot(1,3,3); imshow(f3,[0 1]);