function [P,V,er]=discdynprog(fname,s,z,T,be,opt,varargin)
% DiscDynProg - Discrete Dynamic Programming
%
% [P,V,er]=discdynprog(fname,s,z,T,beta,opt,x1,x2,...)
%
% Input:  fname - filename of the return function
%         s - nx1 grid for endogenous state variable
%         z - mx1 grid for exogenous state variable (Markov chain)
%         T - mxm transition matrix for exogenous state variable
%             (COLUMNS sum to one!)
%         beta - discount factor
%         opt - vector of options (optional: use empty matrix instead
%               or avoid at all)
%               opt(1): Tol in stopping rule (>eps)
%               opt(2): Maximum number of iterations (>1)
%               opt(3): Algorithm (1: sparse LU, 2: BiConjugate Gradients
%                       Stabilized method)
%               (if opt=[] or missing then the following default values
%                are used: Tol=1e-6, MaxIer=500, Alg=1)
%         x1,x2,... - optional arguments to be passed to fname
%
% Output: P  - nxm policy function
%         V  - nxm value function
%         er - error code
%
% Author: Marco Maffezzoli. Ver. 2.0.0, 11/2012.
% The algorithm follows Ch. 4 of "Recursive Macroeconomic Theory, 2ed",
% 2004, by Lars Lundquist and Thomas Sargent quite closely.
% 

if nargin<6
    error('I need at least five input arguments!')
end
if nargin==6||isempty(opt)
    tol=1e-6;
    maxeval=500;
    alg=1;
else
    tol=max(opt(1),eps);
    maxeval=max(round(opt(2)),1);
    alg=max(round(opt(3)),1);
end
er=0;
n=size(s,1);
m=size(z,1);
V=zeros(n,m);
H=cell(m,1);
R=cell(m,1);
objf=str2func(fname);
for j=1:m
    R{j}=objf(repmat(s,1,n),repmat(z(j),n,n),repmat(s',n,1),varargin{:});
end
R=vertcat(R{:});
q=size(R,1);
I=speye(q);
Tbig=kron(T,ones(n,1));
for j=1:maxeval
    [~,P]=max(R+be*Tbig*V',[],2);
    r=R(sub2ind(size(R),(1:q)',P));
    P=reshape(P,n,m);
    for k=1:m
        J=sparse((1:n)',P(:,k),1,n,n);
        H{k}=kron(T(k,:),J);
    end
    switch alg
        case 1
            V1=(I-be*vertcat(H{:}))\r;
        otherwise
            V1=bicgstab((I-be*vertcat(H{:})),r,sqrt(eps),100);
    end
    V1=reshape(V1,n,m);
    dif=norm(V1-V);
    V=V1;
    if dif<=tol*norm(V)
        return
    end
end
V=[];
P=[];
er=1;

end