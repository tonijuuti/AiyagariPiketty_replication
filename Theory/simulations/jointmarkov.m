function lambda=jointmarkov(G,P)
% Author: Marco Maffezzoli. 11/2012. Ver. 1.0.1.
%

Q=Qmatrix(G,P);
lambda=ergodicdist(Q);
lambda=reshape(lambda,size(G));

end

% ------------------------------------------------------------------------

function Q=Qmatrix(G,P)

[n,m]=size(G);
Q=cell(m,1);
for z=1:m
    Q{z}=sparse((1:n)',G(:,z),1,n,n);
end
Q=(kron(P,speye(n))*blkdiag(Q{:}));

end