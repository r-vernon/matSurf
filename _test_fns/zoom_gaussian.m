
t_f = figure;
t_a = axes(t_f);

x = linspace(1,19,1e5);
p = normcdf(x,10,4)*16 +2;
plot(x,p);

genNorm = @(x) normcdf(x,10,4)*16 +2;