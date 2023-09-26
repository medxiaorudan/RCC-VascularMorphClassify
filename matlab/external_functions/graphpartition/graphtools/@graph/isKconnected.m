function kcon=isKconnected(g,k)
% [RR,M]=isKconnected(g,k)
%
% Returns a boolean RR indicating whether or not the (symmetrized) graph k-(vertex) connected

edges0=g.edges;
% symmetrization
edges0=(edges0+edges0')/2;

n=size(edges0,1);


switch k
  case 2
    v=(1:n)';
  case 3
    [v1,v2]=find(triu(ones(n),1));
    v=[v1,v2];
  otherwise
    error('not implemeted for k=%d\n',k)
end

kcon=1;
for i=1:size(v,1);
    % remove nodes
    edges=edges0;
    edges(v(i,:),:)=[];
    edges(:,v(i,:))=[];
    % normalization
    edges=edges./(ones(size(edges,1),1)*sum(edges,1));
    e=eigs(edges,2);
    if abs(e(2)-1)<1e-6
        %fprintf('graph not k-connected\n');
        kcon=0;
        break
    end
end
