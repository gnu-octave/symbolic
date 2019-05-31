%% Copyright (C) 2014-2019 Colin B. Macdonald
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
%% Systems of equations are supported:
%% @example
%% @group
%% syms x y
%% eqns = [y*exp(x) == 16; x^5 == x + x*y^2]
%%   @result{} eqns = (sym 2×1 matrix)
%%
%%       ⎡     x       ⎤
%%       ⎢  y⋅ℯ  = 16  ⎥
%%       ⎢             ⎥
%%       ⎢ 5      2    ⎥
%%       ⎣x  = x⋅y  + x⎦
%% @end group
%%
%% @group
%% vpasolve(eqns, [x; y], [1; 1])
%%   @result{} (sym 2×1 matrix)
%%
%%       ⎡1.7324062670465659633407456995303⎤
%%       ⎢                                 ⎥
%%       ⎣2.8297332667835974266598942031498⎦
%% @end group
%% @end example
%%
%% Complex roots can be found but you must provide a complex initial
%% guess:
%% @example
%% @group
%% vpasolve(x^2 + 2 == 0, x, 1i)
%%   @result{} (sym) 1.4142135623730950488016887242097⋅ⅈ
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

  % everything to column vector
  e = e(:);
  x = x(:);
  x0 = x0(:);

  if (isscalar (x0)) && (numel (x) >= 2)
    x0 = x0 * ones (size (x));
  end

  % IPC cannot pass double matrices yet
  if (isnumeric (x0) && (numel (x0) > 1))
    x0 = num2cell (x0);
  end

  cmd = {
      '(e, x, x0, n) = _ins'
      'import mpmath'
      'mpmath.mp.dps = n'
      'if Version(spver) < Version("1.4"):'
      '    e = list(e) if isinstance(e, Matrix) else e'
      '    x = list(x) if isinstance(x, Matrix) else x'
      '    x0 = list(x0) if isinstance(x0, Matrix) else x0'
      'r = nsolve(e, x, x0)'
      'return r' };
  r = pycall_sympy__ (cmd, sym(e), x, x0, n);

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
%! % (used to fail https://github.com/sympy/sympy/issues/8564)
%! syms x
%! e = x*x == sym(pi);
%! m = digits(256);
%! q = vpasolve(e, x, 3);
%! assert (double(abs(sin(q*q))) < 1e-256)
%! digits(m);

%!test
%! syms x
%! r = vpasolve(x^2 + 2 == 0, x, 1i);
%! assert (double (imag(r)^2 - 2), 0, 1e-32)
%! assert (double (real(r)^2), 0, 1e-32)
%! r = vpasolve(x^2 + 2 == 0, x, -3i + 5);
%! assert (double (imag(r)^2 - 2), 0, 1e-32)
%! assert (double (real(r)^2), 0, 1e-32)

%!test
%! % system
%! syms x y
%! f = 3*x^2 - 2*y^2 - 1;
%! g = x^2 - 2*x + y^2 + 2*y - 8;
%! r = vpasolve([f; g], [x; y], sym([-1; 1]));
%! assert (isa (r, 'sym'))
%! assert (numel (r) == 2)

%!test
%! % system, double guess
%! syms x y
%! f = 3*x^2 - 2*y^2 - 1;
%! g = x^2 - 2*x + y^2 + 2*y - 8;
%! r = vpasolve([f; g], [x; y], [-1.1 1.2]);

%!test
%! % system, double guess
%! syms x y
%! f = 3*x^2 - 2*y^2 - 1;
%! g = x^2 - 2*x + y^2 + 2*y - 8;
%! r1 = vpasolve([f; g], [x; y], [-1.1]);
%! r2 = vpasolve([f; g], [x; y], [-1.1 -1.1]);
%! assert (isequal (r1, r2))

%!test
%! % system, more eqns than unknowns
%! syms x y
%! eqns = [x^3 - x - y == 0; y*exp(x) == 16; log(y) + x == 4*log(sym(2))];
%! r = vpasolve (eqns, [x; y], [1; 1]);
%! A = subs (lhs (eqns), [x; y], r);
%! err = A - [0; 16; 4*log(sym(2))];
%! assert (double (err), zeros (size (err)), 1e-31)
