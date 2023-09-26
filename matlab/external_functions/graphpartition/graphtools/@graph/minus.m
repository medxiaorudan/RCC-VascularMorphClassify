function g=minus(g1,g2)
% g=minus(g1,g2) -- subtracts edge values of two graphs (with the same vertices)
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

if any(size(g1.vertices) ~= size(g2.vertices))
  error('cannot add graphs of different sizes')
end

if any(any(g1.vertices ~= g2.vertices))
  error('cannot add graphs with different vertices')
end

g.vertices=g1.vertices;
g.edges=g1.edges-g2.edges;

% identify class
g = class(g,'graph');
