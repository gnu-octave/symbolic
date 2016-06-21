%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defun  vpasolve (@var{e})
%% @defunx vpasolve (@var{e}, @var{x})
%% @defunx vpasolve (@var{e}, @var{x}, @var{x0})
%% Numerical solution of a symbolic equation.
%%
%% Variable-precision numerical solution of the equation @var{e}
%% for variable @var{x} using initial guess of @var{x0}.
%%
%% Example:
%% @example
%% @group
%% syms x
%% eqn = exp(x) == x + 2;
%% vpasolve(eqn, x, 0.1)
%%   @result{} (sym) 1.1461932206205825852370610285214
%% @end group
%% @end example
%%
%% @seealso{vpa}
%% @end defun

function r = vpasolve(e, x, x0)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  end

  if (nargin < 3)
    x0 = sym(0);
  end
  if (nargin < 2)
    x = symvar(e, 1);
  end

  n = digits();

  % nsolve gives back mpf object: https://github.com/sympy/sympy/issues/6092

  cmd = {
    '(e, x, x0, n) = _ins'
    'import mpmath'
    'mpmath.mp.dps = n'
    'findroot = mpmath.findroot'
    '#r = nsolve(e, x, x0)'  % https://github.com/sympy/sympy/issues/8564
    '#r = sympy.N(r, n)'  % deal with mpf
    'if isinstance(e, Equality):'
    '    e = e.lhs - e.rhs'
    'e = e.evalf(n)'
    'f = lambda meh: e.subs(x, meh)'
    'r = findroot(f, x0)'
    'r = sympy.N(r, n)'  % deal with mpf
    'return r,' };

  r = python_cmd (cmd, sym(e), x, x0, n);

end


%!test
%! syms x
%! vpi = vpa(sym(pi), 64);
%! e = tan(x/4) == 1;
%! q = vpasolve(e, x, 3.0);
%! w = q - vpi ;
%! assert (double(w) < 1e-30)

%!test
%! syms x
%! vpi = vpa(sym(pi), 64);
%! e = tan(x/4) == 1;
%! q = vpasolve(e, x);
%! w = q - vpi;
%! assert (double(w) < 1e-30)
%! q = vpasolve(e);
%! w = q - vpi;
%! assert (double(w) < 1e-30)

%!test
%! % very accurate pi
%! syms x
%! e = tan(x/4) == 1;
%! m = digits(256);
%! q = vpasolve(e, x, 3);
%! assert (double(abs(sin(q))) < 1e-256)
%! digits(m);

%!test
%! % very accurate sqrt 2
%! syms x
%! e = x*x == 2;
%! m = digits(256);
%! q = vpasolve(e, x, 1.5);
%! assert (double(abs(q*q - 2)) < 1e-256)
%! digits(m);

%!test
%! % very accurate sqrt pi
%! % fails: https://github.com/sympy/sympy/issues/8564
%! syms x
%! e = x*x == sym(pi);
%! m = digits(256);
%! q = vpasolve(e, x, 3);
%! assert (double(abs(sin(q*q))) < 1e-256)
%! digits(m);
