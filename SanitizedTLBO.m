function [X, FVAL, BestFVALIter, pop] = SanitizedTLBO(FITNESSFCN,lb,ub,T,NPop)
% Teaching Learning Based optimization (TLBO)
% SanitizedTLBO attempts to solve problems of the following forms:
%         min F(X)  subject to: lb <= X <= ub
%          X
%
%  [X,FVAL,BestFVALIter, pop] = SanitizedTLBO(FITNESSFCN,lb,ub,T,NPop)
%  FITNESSFCN   - function handle of the fitness function
%  lb           - lower bounds on X
%  ub           - upper bounds on X
%  T            - number of iterations
%  NPop         - size of the population (class size)
%  X            - minimum of the fitness function determined by ModifiedTLBO
%  FVAL         - value of the fitness function at the minima (X)
%  BestFVALIter - the best fintess function value in each iteration
%  pop          - the population at the end of the specified number of iterations

% preallocation to store the best objective function of every iteration
% and the objective function value of every student
BestFVALIter = NaN(T,1);
obj = NaN(NPop,1);

% Determining the size of the problem
D = length(lb);

% Generation of initial population
pop = repmat(lb, NPop, 1) + repmat((ub-lb),NPop,1).*rand(NPop,D);


%  Evaluation of objective function
%  Can be vectorized
for p = 1:NPop
    [obj(p)] = FITNESSFCN(pop(p,:));
end


for gen = 1: T
    
    for i = 1:NPop
        
        % ----------------Begining of the Teacher Phase for ith student-------------- %
        mean_stud = mean(pop);
        
        % Determination of teacher
        [~,ind] = min(obj);
        best_stud = pop(ind,:);
        
        % Determination of the teaching factor
        TF = randi([1 2],1,1);
        
        % Generation of a new solution
        NewSol = pop(i,:) + rand(1,D).*(best_stud - TF*mean_stud);
        
        % Bounding of the solution
        NewSol = max(min(ub, NewSol),lb);
        
        % Evaluation of objective function
        [NewSolObj] = FITNESSFCN(NewSol);
        
        % Greedy selection
        if (NewSolObj < obj(i))
            pop(i,:) = NewSol;
            obj(i) = NewSolObj;
        end
        % ----------------Ending of the Teacher Phase for ith student-------------- %
        
        
        % ----------------Begining of the Learner Phase for ith student-------------- %
        % Partner selection for all students
        Partner = randi([1 NPop], 1,1);
        
        % Generation of a new solution
        if (obj(i)< obj(Partner))
            NewSol = pop(i,:) + rand(1, D).*(pop(i,:)- pop(Partner,:));
        else
            NewSol = pop(i,:) + rand(1, D).*(pop(Partner,:)- pop(i,:));
        end
        
        % Bounding of the solution
        NewSol = max(min(ub, NewSol),lb);
        
        % Evaluation of objective function
        [NewSolObj] = FITNESSFCN(NewSol);
        
        % Greedy selection
        if(NewSolObj< obj(i))
            pop(i,:) = NewSol;
            obj(i) = NewSolObj;
        end
        % ----------------Ending of the Learner Phase for ith student-------------- %
        
    end
    
    % This is not part of the algorithm but is used to keep track of the
    % best solution determined till the current iteration
    [BestFVALIter(gen),ind] = min(obj);
end

% Extracting the best solution
X = pop(ind,:);
FVAL = BestFVALIter(gen);