function draw(g,varargin)
% draw(g) -- draws the graph in the current figure
%
% draw(g,parameter,values,parameter,values,...)
%
% This form allows one to pass parameters for the drawing of the dges and
% nodes. Recognized parameters include:
% 'EdgeStyle' : Style for the drawing of the lines that represent the
%               edges. The corresponding value is a line style from the 
%               plot command (see help plot). The deafult is '-' 
% 'NodeStyle' : Style for the drawing of the markers that represent the
%               nodes. The corresponding value is a line style from the 
%               plot command (see help plot). The default is '.'
% 'NodeLabels' : Labels to be drawn at the nodes. The corresponding
%                value is an array of numbers or strings with one row per
%                node. By default no labels are drawn
% 'NodeLabelColor' : Color for the Node labels. The corresponding value is
%                    a color as accepted by the text command (see help
%                    text).
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

dim=2; % reduce to 2d if larger dimension vertices

edgestyle='-';
nodestyle='.';
nodelabelcolor=[0,0,0];
nodelabels=[];

if (rem(nargin,2) == 0)
  error('Number of arguments should be odd') ;
else
  for i=1:2:nargin-1,
    arg1 = varargin{i}; 
    switch(arg1)
    case 'EdgeStyle'
      edgestyle  = varargin{i+1}; 
    case 'NodeStyle'
      nodestyle  = varargin{i+1};
    case 'NodeLabelColor'
      nodelabelcolor  = varargin{i+1}; 
    case 'NodeLabels'
      nodelabels = varargin{i+1};
      if (size(nodelabels,1)~=size(g.vertices,1))
	error('Number of labels does not match number of vertices')
      end	 
    otherwise
      error(sprintf('Unknown option "%s"',arg1))
    end    
  end
end


[n1,n2]=find(g.edges);

% Construct start and finish points for edges
vert=g.vertices;

if (size(vert,2)>2 & dim==2)
  vert=vert(:,1:2);
end

edges=NaN*ones(size(n1,1)*3,size(vert,2));
edges(1:3:end,:)=vert(n1,:);
edges(2:3:end,:)=vert(n2,:);


if (size(vert,2)==2)
  oldhold=ishold;  
  if (~isempty(nodestyle))
    plot(vert(:,1),vert(:,2),nodestyle)
    hold on  
  end    
  if (~isempty(edgestyle))
    plot(edges(:,1),edges(:,2),edgestyle)
    hold on  
  end    
  if (~isempty(nodelabels))
    for i=1:size(vert,1)
      text(vert(i,1),vert(i,2),sprintf('%g',nodelabels(i,:)),...
      ...%      text(vert(i,1),vert(i,2),char(nodelabels(i)),...
      'HorizontalAlignment','center','Color',nodelabelcolor)
      hold on  
    end 
  end    
  if ~oldhold    
    hold off 
  end      
else
  error('unimplemented')
end

