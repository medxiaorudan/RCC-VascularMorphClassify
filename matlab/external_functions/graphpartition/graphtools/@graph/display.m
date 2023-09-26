function display(g)
% display(g) -- displays a graph object
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

disp([inputname(1),'.vertices = '])
disp(g.vertices)
disp([inputname(1),'.edges    = '])
%disp(g.edges)

[i,j,e]=find(g.edges);

for k=1:length(i)
fprintf('    (');
fprintf('%7.4g ',g.vertices(i(k),:));
fprintf(',');
fprintf('%7.4g ',g.vertices(j(k),:));
fprintf(')\t= %g\n',e(k));
end
