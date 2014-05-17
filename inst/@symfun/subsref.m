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
%% @deftypefn  {Function File} {@var{out} =} subsref (@var{f}, @var{idx})
%% Overloaded () reference for symfuns.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function out = subsref (f, idx)

  switch idx.type
    case '()'
      out = subs(f, f.vars, idx.subs);

    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'vars'))
        out = f.vars;
      else
        %out = sym/subsref(f, idx);
        %out = f.sym.fld;
        %warning(' is there a better way to call the superclass fcn?')
        out = subsref(f.sym,idx);
      end

    otherwise
      error ('@symfun/subsref: invalid subscript type ''%s''', idx.type);

  end

end


%!test
%! syms x
%! f(x) = x^2;
%! v = f.vars;
%! assert(iscell(v))
%! assert(length(v)==1)
%! assert(isequal(v{1},x))

%!test
%! %% pass through to sym properties
%! syms x
%! f(x) = x^2;
%! y = x^2;    % not a symfun
%! assert(strcmp(f.flattext, y.flattext))

