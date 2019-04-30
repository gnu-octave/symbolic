%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
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
%% @defmethod  @@symfun symvar (@var{f})
%% @defmethodx @@symfun symvar (@var{f}, @var{n})
%% Find symbols in symfun and return them as a symbolic vector.
%%
%% If @var{n} specified, we take from the explicit function variables
%% first followed by the output of @code{symvar} on any other symbols
%% in the sym (expression) of the symfun.
%%
%% Example:
%% @example
%% @group
%% syms a x f(t, s)
%% symvar (f, 1)
%%   @result{} (sym) t
%% symvar (f, 2)
%%   @result{} (sym) [t  s]  (1×2 matrix)
%% @end group
%% @end example
%% Note preference for the arguments of the symfun:
%% @example
%% @group
%% h = f*a + x
%%   @result{} h(t, s) = (symfun) a⋅f(t, s) + x
%% symvar (h, 1)
%%   @result{} (sym) t
%% symvar (h, 2)
%%   @result{} (sym) [t  s]  (1×2 matrix)
%% symvar (h, 3)
%%   @result{} (sym) [t  s  x]  (1×3 matrix)
%% symvar (h, 4)
%%   @result{} (sym) [t  s  x  a]  (1×4 matrix)
%% @end group
%% @end example
%%
%% On the other hand, if @var{n} is omitted, the results are
%% sorted as explained elsewhere (@pxref{@@sym/symvar}).
%% For example:
%% @example
%% @group
%% symvar (f, 2)
%%   @result{} (sym) [t  s]  (1×2 matrix)
%% symvar (f)
%%   @result{} (sym) [s  t]  (1×2 matrix)
%% symvar (h)
%%   @result{} (sym) [a  s  t  x]  (1×4 matrix)
%% @end group
%% @end example
%%
%% @strong{Compatibility with other implementations}: the output generally
%% matches the equivalent command in the Matlab Symbolic Toolbox
%% (tested with version 2014a).  For example:
%% @example
%% @group
%% syms x y s t
%% f(t, s) = 1
%%   @result{} f(t, s) = (symfun) 1
%% symvar (f, 1)
%%   @result{} (sym) t
%% symvar (f, 2)
%%   @result{} (sym) [t  s]  (1×2 matrix)
%% @end group
%% @end example
%% However, when the symfun formula does not depend on the
%% arguments, the results are not the same:
%% @example
%% @group
%% symvar (f)  % SMT would give []
%%   @result{} (sym) [s  t]  (1×2 matrix)
%% @end group
%% @end example
%%
%% If two variables have the same symbol but different assumptions,
%% they will both appear in the output.  It is not well-defined
%% in what order they appear.
%%
%% @seealso{findsymbols, @@symfun/argnames, @@symfun/formula}
%% @end defmethod

function vars = symvar(F, Nout)

  if (nargin == 1)
    % Note: symvar(symfun) differs from SMT, see test below
    tmp = formula (F);
    vars = symvar([argnames(F) tmp(:)]);

  else
    assert(Nout >= 0, 'number of requested symbols should be positive')

    % take first few from the arguments of the symfun
    vars = argnames (F);
    M = length(vars);
    if (Nout <= M)
      vars = vars(1:Nout);
      return
    end

    symvars = symvar (formula (F), inf);
    symvars = remove_dupes(symvars, vars);
    vars = [vars symvars(1:min(end, Nout-M))];
  end
end

function a = remove_dupes(symvars, vars)
  M = length(vars);
  % ones(1, 3, 'logical') doesn't work in Matlab
  keep = logical(ones(1, length(symvars)));
  for j = 1:length(symvars)
    for i = 1:M
      if (strcmp (sympy (symvars(j)), sympy (vars(i))))
        keep(j) = false;
        break
      end
    end
  end
  a = symvars(keep);
end


%!test
%! % basic
%! syms f(t, s)
%! assert (isempty (symvar (f, 0)))
%! assert (isequal (symvar (f, 1), t))
%! assert (isequal (symvar (f, 2), [t s]))
%! assert (isequal (symvar (f, 3), [t s]))

%!test
%! % note preference for vars of symfun, if n requested
%! syms x f(y)
%! assert (isequal (symvar(f*x, 1), y))
%! assert (isequal (symvar(f(y)*x, 1), x))

%!test
%! % symfun, checked smt
%! syms x f(y)
%! a = f*x;
%! b = f(y)*x;
%! assert (isequal (symvar(a), [x y]))
%! assert (isequal (symvar(b), [x y]))

%!test
%! % preference for the explicit variables
%! syms a x f(t, s)
%! h = f*a + x;
%! assert (isequal (symvar (h, 1), t))
%! assert (isequal (symvar (h, 2), [t s]))
%! assert (isequal (symvar (h, 3), [t s x]))
%! assert (isequal (symvar (h, 4), [t s x a]))
%! assert (isequal (symvar (h, 5), [t s x a]))
%! assert (isequal (symvar (h), [a s t x]))

%!test
%! % symfun dep on some vars only, matches smt w/ n
%! syms x s t
%! f(s) = x;
%! g(s, t) = x*s;
%! assert (isequal (symvar(f, 1), s))
%! assert (isequal (symvar(f, 2), [s x]))
%! assert (isequal (symvar(g, 1), s))
%! assert (isequal (symvar(g, 2), [s t]))
%! assert (isequal (symvar(g, 3), [s t x]))

%!test
%! % A documented difference from SMT on symvar(symfun) w/o n
%! syms x s t
%! f(s) = x;
%! g(s, t) = x*s;
%! % SMT would have
%! %assert (isequal (symvar(f), x))  % no s
%! %assert (isequal (symvar(g), [s x]))  % no t
%! assert (isequal (symvar(f), [s x]))
%! assert (isequal (symvar(g), [s t x]))
