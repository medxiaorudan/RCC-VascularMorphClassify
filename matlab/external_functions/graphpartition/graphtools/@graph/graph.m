function g = graph(varargin)
% g = graph(varargin) -- creates a new object of class graph
%
% Object properties
%    .vertices   array of vertices (one per row). Used as coordinates
%                for ploting
%    .edges      (sparse) adjacency matrix (edges from column to row node)
%
% Initialization commands
% graph('empty',vertices)      - creates a graph with the given vertices and no edges.
% graph(edges,vertices)        - creates a graph with the given vertices and 
%                                edges defined by the given adjacency matrix.
% graph('eye',vertices)        - creates a graph whose only edges are from
%                                a node to itself
% graph('full',vertices)       - creates a fully connected graph
% graph('1d-lattice',vertices) - creates a bidirectional 1d-lattice where each
%                                vertex is connected to the next one
% graph('1d-unilattice',vertices) - creates a unidirectional 1d-lattice where
%                                each vertex is connected to the next one
% graph('2d-deg4-reclattice',{x-vertices,y-vertices}) - creates a bidirectional 
%                                2d-lattice with rectangular cells (degree 4) 
% graph('2d-deg3-hexlattice',{width,height,scale}) - creates a bidirectional 
%                                2d-lattice with hexagonal cells and 
%                                degree 3 nodes
% graph('2d-deg6-trilattice',{width,height,scale}) - creates a bidirectional 
%                                2d-lattice with triangular cells and 
%                                degree 6 nodes
% graph('delaunay',vertices)   - creates a bidirectional delaunay graph for the
%                                given vertex coordinates
% graph('2image-affine-transf',image-size,transformation-matrix) - creates
%                                the graph associates with a given affine 
%                                transformation for a 2d image, the vertices
%                                are the image coordinates of the pixels
%
% Copyright (C) 2004  Joao Hespanha

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
% Modification history:
%
% Before August 27, 2006 
% No idea about what happened before this date...
%
% August 27, 2006
% GNU GPL added

% Construct default object
g.vertices = zeros(0);
g.edges = sparse([],[],[],0,0);  

% with no arguments, we must return a template with null initial values
if 0 == nargin
  g = class(g,'graph');
  return
end

%-------------------------------------------------------------------------
if (rem(nargin,2) == 1)
  error('Number of arguments should be even') ;
else
  for i=1:2:nargin,
    arg1 = varargin{i}; 
    if isnumeric(arg1)
        g.vertices=varargin{i+1};
        g.edges=sparse(arg1);
        g = class(g,'graph');
    elseif ischar(arg1)
        switch(arg1)
          case 'empty'
            g.vertices=varargin{i+1};
            g.edges=sparse([],[],[],size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          case 'eye'
            g.vertices=varargin{i+1};
            g.edges=sparse(1:size(g.vertices,1),1:size(g.vertices,1),1,...
                           size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          case 'full'
            g.vertices=varargin{i+1};
            g.edges=sparse(ones(size(g.vertices,1),size(g.vertices,1)));
            g = class(g,'graph');
          case '1d-lattice'
            g.vertices=varargin{i+1};  
            g.edges=spdiags(ones(size(g.vertices,1),2),[-1,1],...
                            size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          case '1d-unilattice'
            g.vertices=varargin{i+1};  
            g.edges=spdiags(ones(size(g.vertices,1),1),-1,...
                            size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          case '2d-deg4-reclattice'
            v=varargin{i+1};  	
            g1=graph('eye',v{1});
            g2=graph('1d-lattice',v{2});
            g=g1*g2;
            g1=graph('1d-lattice',v{1});
            g2=graph('eye',v{2});
            g=g+g1*g2;
            setEdgesSelf(g,0);	
          case '2d-deg6-trilattice'
            v=varargin{i+1};  	
            vx=v{3}*(0:v{1}-1)';
            vy=v{3}*sqrt(3)/2*(0:v{2}-1)';
            g=graph('2d-deg4-reclattice',{vx,vy});
            g1=graph('1d-unilattice',vx);
            g2=graph('1d-unilattice',vy);
            e=g2.edges;e=e+e';e(1:2:end,:)=0;g2.edges=e;
            g=g+g1*g2;
            dv=zeros(length(vy),2);
            dv(1:2:end,1)=.5*v{3};	
            g.vertices=g.vertices+repmat(dv,length(vx),1);	
            g=g+g';   % make symmetric
            g.edges=spones(g.edges);
          case '2d-deg3-hexlattice'
            v=varargin{i+1};  	
            vx=v{3}*(0:v{1}-1)';
            vy=v{3}*sqrt(3)/2*(0:v{2}-1)';
            g=graph('2d-deg6-trilattice',v);
            b0=repmat([1;0;0],ceil(length(vx)/3),1);
            b0=b0(1:length(vx));
            b1=repmat([0;0;1],ceil(length(vx)/3),1);
            b1=b1(1:length(vx));
            bb=repmat([b0';b1'],ceil(length(vy)/2),1);
            bb=bb(1:length(vy),:);	
            k=find(bb);
            vv=g.vertices;vv(k,:)=[];g.vertices=vv;
            ee=g.edges;ee(k,:)=[];ee(:,k)=[];g.edges=ee;
          case 'delaunay'
            g.vertices=varargin{i+1}; 
            tri=delaunayn(g.vertices,{'QJ'});
            edges=[tri(:,1),tri(:,2);
                   tri(:,2),tri(:,3);
                   tri(:,3),tri(:,1)];
            % remove repeated edges
            edges=unique(sort(edges')','rows');  
            edges=[edges;edges(:,2),edges(:,1)];  % symmetrize
            g.edges=sparse(edges(:,1),edges(:,2),1,...
                           size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          case '2image-affine-transf'
            args=varargin{i+1};
            g.vertices=zeros(prod(args{1}),2);
            T=args{2};	
            v=1:size(g.vertices,1);
            [g.vertices(:,1),g.vertices(:,2)]=ind2sub(args{1},v');
            vv=round(T*[g.vertices';ones(1,size(g.vertices,1))]);
            k=find(vv(1,:)<1 | vv(1,:)>args{1}(1) | vv(2,:)<1 | vv(2,:)>args{1}(2));
            v(:,k)=[];	
            vv(:,k)=[];	
            vv=sub2ind(args{1},vv(1,:),vv(2,:));
            g.edges=sparse(vv,v,1,size(g.vertices,1),size(g.vertices,1));
            g = class(g,'graph');
          otherwise
            error('Unknown option "%s"\n',arg1)
        end
    else
        disp(arg1)
        error('Unexpected 1st argument\n');
    end
  end
end
