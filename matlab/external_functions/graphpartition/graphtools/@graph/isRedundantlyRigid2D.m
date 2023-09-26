function [RR,M]=isRedundantlyRigid2D(g,tol)
% [RR,M]=isRedundantlyRigid2D(g)
%
% Returns a boolean RR indicating whether or not the graph is redudantly rigid in 2D. 
%
% Also computes the rigidity matrix of (a symmetrized version of) the graph, based on which
% the test is performed.

M=rigidityMatrix2D(g);

n=size(M,2)/2;

if n<4
    error('not implemented');
end

S=2*n-3;

RR=1;
for i=1:size(M,1)
    N=M;
    N(i,:)=[];
    if nargin<2
        if rank(N)<S
            RR=0;
            break
        end
    else
        if rank(N,tol)<S
            RR=0;
            break
        end
    end
end
