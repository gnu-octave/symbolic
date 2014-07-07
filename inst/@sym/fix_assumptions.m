%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn  {Function File} {[@var{flag}, @var{newobj}]} = fix_assumptions(@var{obj}, @{newx}, @var{xstr})
%% Recurvsively replace instances of once symbolic variable with another.
%%
%% Look in @var{obj} for symbolic variables whose string matches
%% @var{xstr}, and replaces them with @var{newx}.  If the object is
%% changed @var{flag} will be nonzero and @var{newobj} contains the
%% new object.  In the case of cell arrays and structs, this calls
%% itself recursively.
%%
%% @seealso{assume, assumeAlso, assumptions, symreplace, sym, syms}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [flag, newobj] = fix_assumptions(obj, newx, xstr)

  flag = false;

  if isa(obj, 'sym')
    % check if contains any symbols with the same string as x.
    symlist = findsymbols(obj);
    for c = 1:length(symlist)
      if strcmp(xstr, strtrim(disp(symlist{c})))
        flag = true;
        break
      end
    end
    % If so, subs in the new x and replace that variable.
    if (flag)
      newobj = subs(obj, symlist{c}, newx);
    end
    if isa(obj, 'symfun')
      warning('FIXME: need to do anything special for symfun vars?')
    end

  elseif iscell(obj)
    fprintf('Replacing inside cell array of numel=%d\n', numel(obj))
    newobj = obj;
    flag = false;
    for i=1:numel(obj)
      [flg, temp] = fix_assumptions(obj{i}, newx, xstr);
      if (flg)
        newobj{i} = temp;
        flag = true;
      end
    end

  elseif isstruct(obj)
    fprintf('Replacing inside a struct array of numel=%d\n', numel(obj))
    newobj = obj;
    fields = fieldnames(obj);
    for i=1:numel(obj)
      for j=1:length(fields)
        thisobj = getfield(obj, {i}, fields{j});
        [flg, temp] = fix_assumptions(thisobj, newx, xstr);
        if (flg)
          % This requires work on octave but not on matlab!  Instead, gratuitous
          % use of eval()...
          %newobj = setfield(newobj, {i}, fields{j}, temp);
          eval(sprintf('newobj(%d).%s = temp;', i, fields{j}));
          flag = true;
        end
      end
    end
  end

  if ~(flag)
    newobj = [];
  end
