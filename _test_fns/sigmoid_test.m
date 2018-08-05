
x = linspace(0,1,1e6);
logFun = @(x,x0,k) 1./(1+exp(k*(x-x0)));

a1 = 0.45;
b1 = 0.3;

a2 = 0.7;
b2 = 0.55;

% 1/18 = (100-95)/95
k(1) = 2/(b1-a1) * log(1/99); 
k(2) = 2/(b2-a2) * log(1/99); 
k(3) = 2/(b1-a2) * log(1/99); 
x0(1) = (a1+b1)/2;
x0(2) = (a2+b2)/2;
x0(3) = (b1+a2)/2;

y1 = logFun(x,x0(1),k(1));
y2 = logFun(x,x0(2),k(2));
y3 = logFun(x,x0(3),k(3));
y4 = y1.*y3 + y2.*(1-y3);

figure;
subplot 221
plot(x,y1);
subplot 222
plot(x,y2);
subplot 223
plot(x,y3);
subplot 224
plot(x,y4);