%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Aiyagari 1994 - Uninsured Idiosyncratic Risk and Aggregate Saving %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Author: Teemu Pekkarinen, University of Helsinki, Helsinki GSE
% teemu.pekkarinen@helsinki.fi

% I am indebted to Associate Professor Marco Maffezzoli, Universita Bocconi
% whose Matlab codes my scripts are based on:
% https://didattica.unibocconi.eu/myigier/index.php?IdUte=49183&idr=19215&lingua=eng&comando=Apri
% https://didattica.unibocconi.eu/mypage/index.php?IdUte=49183&idr=6862&lingua=eng

% Takes approximately 878.134458 seconds to run this code
clear;
close all;
tic

%% Credit Constraints %%
CREDIT=0:0.5:2;

%% Income Inequality Shock %%
SIG=[0.29;0.30]; % Try also [m = 7 with beta = 0.97 with rho = 0 and sigma = [0.19;0.2] or [0.29;0.3] or [0.39;0.4]] or m = 2 with beta = 0.96, or m = 2, [0.30;0.31] and beta = 0.97;

%% Capital Share of Income %%
A = 0.1:0.1:0.5;
diffY=zeros(length(A),length(CREDIT));

%% Parameters %%
mu=3; % The Relative Risk Aversion Coefficient
beta=0.97; % Discount Rate (Yearly)
delta=0.08; % Depreciation Rate

%% Simulations
for z = 1:length(CREDIT)
AGG = zeros(length(A),13,length(SIG)); % Aggregate Values
for y = 1:length(SIG)

%% Income Process / Markov Chain by Rouwenhorst Method %%
% Process log(l(t+1)) = rho log(l(t)) + sigma*sqrt(1-rho^2) e(t), e(t) - N(0,1) % The Labor Endowment Shock 
rho=0; % The Serial Correlation % Try also rho = 0.1 
sigma=SIG(y); % The Coefficient of Variation
m=7; % Number of Nodes for Endowment States l
[l,P]=rouwenhorst(m,0,rho,sigma*sqrt(1-rho^2)); % log-States l and Transition Matrix P
Ps=ergodicdist(P); % Ergodic Distribution for l
l=exp(l); % States l

%% Asset Grid %%
n=500; % Number of Asset Levels
kmax=50; % Maximum Level of Assets
kmin=CREDIT(z); % Minimum Level of Assets
knat=-min(l); % Natural Borrowing Constraint -min(s) w / r < -min(s) for All w > r.
k=uniformnodes(kmin,kmax,n); % Asset Grid
L=1; % Labor Normalized to Unity 

for x = 1:length(A)
%% Reparameterization %%
alpha = A(x);

%% Equilibrium %%
[Kss,out]=ridders('aiyagari_eq',-15,30,1e-5,k,l,P,beta,mu,alpha,delta,L);
lambda=out{1}; % Stationary Distribution
dist=sum(out{1},2); % Distribution for Each Asset Levels / Population in Equilibrium
r=alpha*Kss^(alpha-1)*L^(1-alpha)-delta; % Equilibrium Interest Rate
w=(1-alpha)*Kss^alpha*L^(-alpha); % Equilibrium Wage
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
% subplot(1,3,1);
gini_inc = gini(Ps,l*w,false); % Income Inequality
gini_w = gini(dist,wealth*Ps,false); % Wealth Inequality
gini_iw = gini(dist,total_wealth*Ps,false); % Total Wealth Inequality

%% Results %%
K = dist'* (g * Ps); % Aggregate Capital
Y = (K)^(alpha)*L^(1-alpha); % Aggregate Income
s = delta*alpha/(r+delta); % Equilibrium Savings Rate
C = (1-s)*Y; % Aggregate Consumption by Aggregate Resource Constraint
I = s*Y; % Aggregate Investments by Aggregate Resource Constraint
disp(table(Y,K,C,I,r,w,s,alpha,gini_inc,gini_w,gini_iw)); % Summary

%% Aggregate Variables %%
AGG(x,:,y) = [Y,K,C,I,L,W,r,w,s,alpha,gini_inc,gini_w,gini_iw];

end

end
diffY(:,z)=AGG(:,1,2)-AGG(:,1,1);
end

%% Figures %%
plot(A,diffY,'LineWidth',1.5);
hold on
plot(A,zeros(5,1),'--','col','black');
hold off
legend('\Delta Y | A_1=0.0','\Delta Y | A_1=0.5','\Delta Y | A_1=1.0','\Delta Y | A_1=1.5','\Delta Y | A_1=2.0','Location','northwest');

toc