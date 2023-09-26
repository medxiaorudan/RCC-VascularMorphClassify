function b = subsref(s,index)
% subsref -- defines field name indexing for graphs
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

switch length(index)
 case 1
  switch index(1).type
   case '.'
    b=eval(['s.',index(1).subs]);
   case '()'
    error('Array indexing not supported by this type of objects')
   case '{}'
    error('Cell array indexing not supported by this type of objects')
  end
 case 2
  if index(1).type=='.' & (index(2).type=='()'|index(2).type=='{}') ...
	& length(index(2).subs)==1 
    % single index
    if index(2).subs{1}==':';
      ndx=':';
    else
      index(2).subs{1}=index(2).subs{1}(:)';
      ndx=['[',num2str(index(2).subs{1}),']'];
    end
    %    ['s.',index(1).subs,index(2).type(1),ndx,index(2).type(2)] 
    b=eval(['s.',index(1).subs,index(2).type(1),ndx,index(2).type(2)]);
  elseif index(1).type=='.' &  (index(2).type=='()'|index(2).type=='{}') ...
	& length(index(2).subs)==2 
    % double index
    if index(2).subs{1}==':';
      ndx1=':';
    else
      index(2).subs{1}=index(2).subs{1}(:)';
      ndx1=['[',num2str(index(2).subs{1}),']'];
    end
    if index(2).subs{2}==':';
      ndx2=':';
    else
      index(2).subs{1}=index(2).subs{2}(:)';
      ndx2=['[',num2str(index(2).subs{2}),']'];
    end
    %    ['s.',index(1).subs,index(2).type(1),ndx1,',',ndx2,index(2).type(2)]
    b=eval(['s.',index(1).subs,index(2).type(1),ndx1,',',ndx2,index(2).type(2)]);
  else
    error('indexing form not supported by this type of objects')
  end
end

