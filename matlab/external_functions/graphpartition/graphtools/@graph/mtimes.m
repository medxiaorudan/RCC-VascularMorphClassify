function g=mtimes(g1,g2)
% g=mtimes(g1,g2) or g1*g2  -- cartesian product of two graphs
%
% vertex set is the cartesian product of the vertex sets
% the edge set is defined by
%    (v1,v2)->(u1,u2) in g iff v1->u1 in g1 && v2->u2 in g2 
% and the edge value is the product of the corresponding edge values
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
% Auguest 27, 2006
% GNU GPL added


if ~isa(g2,'graph')
  error('mtime(graph,graph): second argument not a graph');  
end  

g.vertices=[kron(g1.vertices,ones(size(g2.vertices,1),1)),...
      kron(ones(size(g1.vertices,1),1),g2.vertices)];

g.edges=kron(g1.edges,g2.edges);

%%% could also be done as follows
%[i1,j1,e1]=find(g1.edges);
%[i2,j2,e2]=find(g2.edges);
%i=kron((i1-1)*size(g2.vertices,1),ones(size(i2,1),1))+kron(ones(size(i1,1),1),i2);
%j=kron((j1-1)*size(g2.vertices,1),ones(size(j2,1),1))+kron(ones(size(j1,1),1),j2);
%e=kron(e1,e2);
%g.edges=sparse(i,j,e,size(g.vertices,1),size(g.vertices,1));

% identify class
g = class(g,'graph');
  

