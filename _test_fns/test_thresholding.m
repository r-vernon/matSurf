

maskCat = {'a','g','s'}; % absolute, graded or sigmoid

currMask = 'a';

a = linspace(0,1,1e6)';
m = zeros(size(a));

lf_min = 0.2;
lf_max = inf;
flip_lf = 1;

hf_min = 0.6;
hf_max = inf;
flip_hf = 0;

switch currMask
    case 'a' % absolute
        
        % deal with left thresholding
        if flip_lf
            m(a <= lf_min) = 1;
        else
            