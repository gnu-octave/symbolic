%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defun dilog (@var{x})
%% Numerical dilogarithm function
%%
%% Example:
%% @example
%% @group
%% dilog (1.1)
%%   @result{} ans = -0.097605
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{polylog}.
%%
%% @seealso{@@sym/dilog}
%% @end defun


function y = dilog (x)
  if (nargin ~= 1)
    print_usage ();
  end
  cmd = { 'L = _ins[0]'
          'A = [complex(mpmath.polylog(2, 1-x)) for x in L]'
          'return A,' };
  c = pycall_sympy__ (cmd, num2cell(x(:)));
  assert (numel (c) == numel (x))
  y = x;
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = dilog (x);
%! B = double (dilog (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 2 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = dilog (x);
%! B = double (dilog (y));
%! assert (A, B, -eps);

%!test
%! % maple:
%! % > A := [1+2*I, -2 + 5*I, 100, 10*I, -1e-4 + 1e-6*I, -20 + I];
%! % > for a in A do evalf(dilog(a)) end do;
%! x = [1+2i; -2+5i; 100; 10i; -1e-4 + 1e-6*1i; -20-1i];
%! A = [ -0.59248494924959145800 - 1.5760154034463234224*1i
%!       -1.0549087538833908441 - 3.8759788000863368495*1i
%!       -12.192421669033171348
%!       -2.9195729380904939394 - 3.9540920181102973073*1i
%!        1.6459519160623984119 - 0.00032335296277550987686*1i
%!       -1.5445800511775466879 + 9.4256034277816069684*1i ];
%! B = dilog (x);
%! assert (A, B, -eps)

%!xtest
%! % https://github.com/fredrik-johansson/mpmath/issues/473
%! assert (isinf (dilog (inf)))

%!assert (isnan (dilog (-inf)))
