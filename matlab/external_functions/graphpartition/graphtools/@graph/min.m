function [mn,i]=min(g,dim)
% mn=min(g,dim) -- returns the minimum (nonzero) edge along dimension dim
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

edges=g.edges;

k=find(edges);
offset=-max(edges(k))-1;
edges(k)=edges(k)+offset; % offset so that maximum for nonzeros is at most -1
[mn,i]=min(edges,[],dim);
mn=mn-offset;             % remove offset
