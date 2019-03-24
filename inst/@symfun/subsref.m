%% Copyright (C) 2014, 2016-2017, 2019 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @defop  Method   @@symfun subsref {(@var{f}, @var{idx})}
%% @defopx Operator @@symfun {@var{f}(@var{x})} {}
%% Evaluate a symfun at a particular value.
%%
%% Example:
%% @example
%% @group
%% syms x
%% f(x) = sin(x);
%% f(2)
%%   @result{} (sym) sin(2)
%%
%% syms h(x, y)
%% h(2, 3)
%%   @result{} (sym) h(2, 3)
%% @end group
%% @end example
%%
%% @seealso{@@sym/subsref}
%% @end defop

function out = subsref (f, idx)

  switch idx.type
    case '()'
      out = subs (formula (f), argnames (f), idx.subs);

    case '.'
      fld = idx.subs;
      if (strcmp (fld, 'vars'))
        out = f.vars;
      elseif (strcmp (fld, 'sym'))
        % TODO: we previously supported a symfun.sym property/method/whatever
        % which developers used to mean "cast to sym".  But that might not be
        % correct and should probably be deprecated/removed.  In most cases,
        % you probably want "formula(f)".
        out = formula (f);
      else
        out = subsref (formula (f), idx);
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
%! assert(strcmp(f.flat, y.flat))
