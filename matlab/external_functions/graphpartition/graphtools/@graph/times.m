function g=times(g1,g2)
% g=times(g1,g2) -- entrywise product of two graphs (with the same vertices)
%
% If g2 is a scalar then edges will be multiplied by g2
%
% If g2 is an array with length equal to the number of vertices 
%    then each column of the edge matrix is multiplied by the
%    corresponding entry of g2 
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

if isa(g2,'graph')
  if any(size(g1.vertices) ~= size(g2.vertices))
    error('cannot .* graphs of different sizes')
  end
  
  if any(any(g1.vertices ~= g2.vertices))
    error('cannot .* graphs with different vertices')
  end
  
  g.vertices=g1.vertices;
  g.edges=g1.edges.*g2.edges;
  
  % identify class
  g = class(g,'graph');
elseif isnumeric(g2)
  if all(size(g2)==[1,1])  % product by scalar 
    g=g1;
    g.edges=g2*g.edges;  
  elseif all(size(g2)==[size(g1.vertices,1),1])
    g=g1;
    [i,j,e]=find(g.edges);
    setEdges(g,i,j,e.*g2(j));
  else
    error ('cannot .* graph by array of wrong size')   
  end    
end  
  
