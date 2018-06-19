clc;clear;

Ncases = 8;
Nruns = 51;


for ca = 1:Ncases
    
    [lb,ub,fobj] = ProblemDetails(ca);
    
    for rs=1:Nruns
        
        rng(rs,'twister')
        
        [~, FVAL(rs,ca), ~, ~] = SanitizedTLBO(fobj,lb,ub,250,200);
        
    end
end