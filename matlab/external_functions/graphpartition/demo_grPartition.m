clear all; clear functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo 1 - Partitioning of a fully connected graph with edge
% weights as a decreasing function of distance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);clf
X=rand(200,2);               % place random points in the plane
C=pdist(X,'euclidean');      % compute distance between points
C=exp(-.1*squareform(C));    % edge cost is a negative exponential of distance

k=6;                         % # of partitions
[ndx,Pi,cost]= grPartition(C,k,30);

colors=hsv(k);               % plots points with appropriate colors
colormap(colors)
cla
line(X(:,1),X(:,2),'MarkerEdgeColor',[0,0,0],'linestyle','none','marker','.');
for i=1:k
  line(X(find(ndx==i),1),X(find(ndx==i),2),...
      'MarkerEdgeColor',colors(i,:),'linestyle','none','marker','.','markersize',15);
end
axis equal
title(sprintf('fully connected graph: cost %g',cost))
colorbar

if exist('graph')~=2
  error('The following demos require the @graph class, available at http://www.ece.ucsb.edu/~hespanha');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo 2 - Partitioning of a 2-dimensional hexagonal lattice with edge
% weights as a decreasing function of distance. 
%
% This example requires the @graph class, available at
% http://www.ece.ucsb.edu/~hespanha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% start with a 2-dimensional hexagonal lattice with degree 3
g=graph('2d-deg3-hexlattice',{20,10,3});
% initially the weights are the distances between the vertices
g=distance(g);
% for each edge, replace the weights by a decaying function of distance
cost=g.edges;
nz=find(g.edges);
cost(nz)=exp(-.1*cost(nz));
g.edges=cost;

figure(gcf+1);clf
draw(g,'EdgeStyle','k:')
axis equal

% do the partitioning
k=6;                         % # of partitions
[ndx,Pi,cost]= grPartition(g.edges,k,30);

colors=hsv(k);               % plots points with appropriate colors
colormap(colors)
for i=1:k
  line(g.vertices(find(ndx==i),1),g.vertices(find(ndx==i),2),...
      'MarkerEdgeColor',colors(i,:),'linestyle','none','marker','.','markersize',15);
end
title(sprintf('2d hex-lattice: cost %g',cost))
colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo 3 - Partitioning of a Delaunay graph with edge weights as a
% decreasing function of distance.
%
% This example requires the @graph class, available at
% http://www.ece.ucsb.edu/~hespanha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% start with a 2-dimensional hexagonal lattice with degree 3
g=graph('delaunay',rand(100,2));
% initially the weights are the distances between the vertices
g=distance(g);
% for each edge, replace the weights by a decaying function of distance
cost=g.edges;
nz=find(g.edges);
cost(nz)=exp(-.1*cost(nz));
g.edges=cost;

figure(gcf+1);clf
draw(g,'EdgeStyle','k:')
axis equal

% do the partitioning
k=6;                         % # of partitions
t0=clock;
[ndx,Pi,cost]= grPartition(g.edges,k,30);
t1=clock;

colors=hsv(k);               % plots points with appropriate colors
colormap(colors)
for i=1:k
  line(g.vertices(find(ndx==i),1),g.vertices(find(ndx==i),2),...
      'MarkerEdgeColor',colors(i,:),'linestyle','none','marker','.','markersize',15);
end
title(sprintf('Delaunay graph with %d nodes and %d edges : cost %g (%gsec)',size(ndx,1),nnz(g.edges),cost,etime(t1,t0)))
colorbar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo 4 - Same as Demo 3, but with a very large graph.
%
% This example requires the @graph class, available at
% http://www.ece.ucsb.edu/~hespanha
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% start with a 2-dimensional hexagonal lattice with degree 3
t0=clock;
g=graph('delaunay',rand(10000,2));
% initially the weights are the distances between the vertices
g=distance(g);
% for each edge, replace the weights by a decaying function of distance
cost=g.edges;
nz=find(g.edges);
cost(nz)=exp(-.1*cost(nz));
g.edges=cost;
fprintf('Creation of graph took %fsec\n',etime(clock,t0));

figure(gcf+1);clf
draw(g,'EdgeStyle','k:')
axis equal

% do the partitioning
k=6;                         % # of partitions
t0=clock;
[ndx,Pi,cost]= grPartition(g.edges,k,30);
t1=clock;
fprintf('Graph partition took %fsec\n',etime(t1,t0));

colors=hsv(k);               % plots points with appropriate colors
colormap(colors)
for i=1:k
  line(g.vertices(find(ndx==i),1),g.vertices(find(ndx==i),2),...
      'MarkerEdgeColor',colors(i,:),'linestyle','none','marker','.','markersize',15);
end
title(sprintf('Delaunay graph with %d nodes and %d edges : cost %g (%gsec)',size(ndx,1),nnz(g.edges),cost,etime(t1,t0)))
colorbar
