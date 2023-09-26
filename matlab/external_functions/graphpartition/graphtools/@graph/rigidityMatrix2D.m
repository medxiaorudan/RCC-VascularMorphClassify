function [M,rankM]=rigidityMatrix2D(g)
% M=rigidityMatrix2D(g)
% Computes the rigidity matrix of (a symmetrized version of) the graph.
%
% [M,rankM]=rigidityMatrix2D(g)
% Computes the rigidity matrix of (a symmetrized version of) the graph and its rank.

    A=triu((g.edges+g.edges')/2,1);
    [v1,v2]=find(A);
    
    M=zeros(length(v1),size(g.vertices,1));
    %clear M  % allows for different types in g.vertices (e.g. symbols), but inneficient in constructing M
    for i=length(v1):-1:1
        M(i,[2*v1(i)+(-1:0),2*v2(i)+(-1:0)])=[g.vertices(v1(i),:)-g.vertices(v2(i),:),-g.vertices(v1(i),:)+g.vertices(v2(i),:)];
    end
    
    if nargout>1
        rankM=rank(M);
    end
    
    if 0
        %% Example 1
        syms x1 x2 x3 x4 y1 y2 y3 y4
        g=graph(sparse([1,2,3,4,4],...
                       [2,3,4,1,2],...
                       ones(1,5)),...
                [x1,y1;x2,y2;x3,y3;x4,y4]);
        M=rigidityMatrix(g)

        g=graph(sparse([1,2,3,4,4],...
                       [2,3,4,1,2],...
                       ones(1,5)),...
                rand(4,2));
        M=rigidityMatrix(g)
        [M,rankM]=rigidityMatrix(g)
    end
end

