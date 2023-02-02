%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Aiyagari 1994 - Uninsured Idiosyncratic Risk and Aggregate Saving %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Author: Teemu Pekkarinen, University of Helsinki, Helsinki GSE %%
% teemu.pekkarinen@helsinki.fi

% I am indebted to Associate Professor Marco Maffezzoli, Universita Bocconi
% whose Matlab codes my scripts are based on:
% https://didattica.unibocconi.eu/myigier/index.php?IdUte=49183&idr=19215&lingua=eng&comando=Apri
% https://didattica.unibocconi.eu/mypage/index.php?IdUte=49183&idr=6862&lingua=eng

% Takes approximately 15.315060 seconds to run this code
clear;
close all;
tic

%% Parameters %%
mu=3; % The Relative Risk Aversion Coefficient
beta=0.96; % Discount Rate (Yearly)
alpha=0.3; % Capital Share of Income. AiyagariManyRounds script goes through all alphas in {0.1,0.2,0.3,0.4,0.5}
delta=0.08; % Depreciation Rate

%% Income Process / Markov Chain by Rouwenhorst Method %%
% AR(1)-Process log(l(t)) = rho log(l(t-1)) + sigma*sqrt(1-rho^2) e(t), e(t) - N(0,1)
rho=0.0; % The Serial Correlation
sigma=0.3; % The Coefficient of Variation. To generate the desired shock, run with sigma = 0.29 and with sigma = 0.3 and compare the results. AiyagariManyRounds script does this.
m=7; % Number of Nodes for States s
[l,P]=rouwenhorst(m,0,rho,sigma*sqrt(1-rho^2)); % log-States s and Transition Matrix P
Ps=ergodicdist(P); % Ergodic Distribution for s
l=exp(l); % States s

%% Asset Grid %%
n=500; % Number of Asset Levels
kmax=50; % Maximum Level of Assets
kmin=0; % Minimum Level of Assets. AiyagariManyRounds script runs through this code with all credit constraints {0.0,0.5,1.0,1.5,2.0}
knat=-min(l); % Natural Borrowing Constraint -min(s) w / r < -min(s) for All w > r.
k=uniformnodes(kmin,kmax,n); % Asset Grid
L=1; % Labor Normalized to Unity 

%% Equilibrium %%
[K,out]=ridders('aiyagari_eq',-2,10,1e-5,k,l,P,beta,mu,alpha,delta,L); % Aggregate Capital
lambda=out{1}; % Stationary Distribution
dist=sum(out{1},2); % Distribution for Each Asset Levels / Population in Equilibrium
r=alpha*K^(alpha-1)*L^(1-alpha)-delta; % Equilibrium Interest Rate
w=(1-alpha)*K^alpha*L^(-alpha); % Equilibrium Wage
G = out{2}; % Index for the Optimal Asset Levels Conditional on States (a,s)
c = zeros(n,m);
g = zeros(n,m);
income = zeros(n,m);
wealth = zeros(n,m);
for ss = 1:m
    for aa = 1:n
        income(aa,ss) =  w * l(ss);
        wealth(aa,ss) = (1+r)*k(aa);
        g(aa,ss) = k(G(aa,ss)); % Optimal Asset Levels (a') Conditional on States (a,s)
        c(aa,ss) = wealth(aa,ss) + income(aa,ss) - g(aa,ss); % Optimal Consumption (c) Conditional on States (a,s)
    end
end

%% Wealth Distributions %% 
total_wealth = income + wealth; % Wealth Conditional on State (a,s)
W = dist'* (total_wealth * Ps); % Aggregate Wealth (K+C)
subplot(1,3,1);
gini_i = gini(Ps,l*w,true); % Income Inequality
title(join(['Income Ineq. - gini ',num2str(gini_i)]))  
subplot(1,3,2);
gini_w = gini(dist,wealth*Ps,true); % Wealth Inequality
title(join(['Wealth Ineq. - gini ',num2str(gini_w)]))  
subplot(1,3,3);
gini = gini(dist,total_wealth*Ps,true); % Total Wealth Inequality
title(join(['Inc. + Wealth Ineq. - gini ',num2str(gini)]))  

%% Results %%
C = dist'* (c * Ps); % Aggregate Consumption
Y = K^(alpha)*L^(1-alpha); % Aggregate Income
I = Y - C; % Aggregate Investments by Aggregate Resource Constraint
s = delta*K / (K)^alpha; % Equilibrium Savings Rate
disp(table(Y,K,C,I,L,W,r,w,s,alpha,gini_i,gini_w,gini)); % Summary

%% Figures %%
figure();
plot(k,dist) % Asset level distribution

toc