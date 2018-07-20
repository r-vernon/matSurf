function timeTest

a = zeros(1e6,1);

for i = 1:1000
    
    nFill = round(rand(1)*1e6);
    a(1:nFill) = 1;
    
    b = sum(any(a,2));
    c = nnz(a);
    
end 
   
end