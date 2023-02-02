function [res,out]=aiyagari_eq(Kss,k,s,P,beta,mu,alpha,delta,N)

r=alpha*(Kss)^(alpha-1)*N^(1-alpha)-delta;
w=(1-alpha)*(Kss)^alpha*N^(-alpha);
[G,V]=discdynprog('aiyagari_obj',k,s,P',beta,[],mu,w,r);
lambda=jointmarkov(G,P);
out={lambda,G,V};
Kss1=sum(sum(k(G).*lambda));
res=Kss1-Kss;