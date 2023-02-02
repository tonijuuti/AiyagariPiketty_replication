function U=aiyagari_obj(K,S,K1,mu,w,r)

C=(1+r)*K+w*S-K1;
ind=find(C>0);
U=repmat(-inf,size(C));
if mu == 1
    U(ind)=log(C(ind));
else
    U(ind)=(C(ind).^(1-mu)-1)/(1-mu);
end