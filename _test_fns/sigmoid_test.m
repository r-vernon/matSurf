
logFun = @(x,x0,k) 1./(1+exp(-k*(x-x0)));

a = 3;
b = 5;
thr = 0.95;



x0 = a + (b-a)/2;
k = -log((1-thr)/thr);
x = linspace(a-1,b+1,1e6);

c = logFun(x,x0,k);

figure;
plot(x,c);