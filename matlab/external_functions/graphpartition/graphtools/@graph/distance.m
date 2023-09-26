function dg=distance(g)
% dg=distance(g) -- creates a graph with edge weights equal to the node distances
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

dg.vertices=g.vertices;
[n1,n2]=find(g.edges);

% adds eps to avoid zero-distances (no edge)
d=sqrt(sum((g.vertices(n1,:)-g.vertices(n2,:)).^2,2))+eps;

dg.edges=sparse(n1,n2,d,size(g.edges,1),size(g.edges,2));

% identify class
dg = class(dg,'graph');



