%% Copyright (C) 2018-2019 Colin B. Macdonald
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
%% @defun chebyshevU (@var{n}, @var{x})
%% Numerically evaluate Chebyshev polynomials of the second kind.
%%
%% Evaluates the Chebyshev polynomial of the second kind of degree
%% @var{n} at the point @var{x}, in double precision.  Both inputs
%% can be arrays but their sizes must be either the same or scalar.
%%
%% Example:
%% @example
%% @group
%% chebyshevU (18, 0.9)
%%   @result{} ans = 1.7315
%% @end group
%% @end example
%%
%% Using this function may be preferable to evaluating the polynomial
%% in monomial form because the latter can give poor accuracy due to
%% numerical instability.  For example, consider evaluating the
%% Chebyshev polynomial of degree 10 at a point by evaluating
%% in the monomial basis:
%% @example
%% @group
%% syms n x
%% C = chebyshevU (10, x)
%%   @result{} C = (sym)
%%             10         8         6        4       2
%%       1024⋅x   - 2304⋅x  + 1792⋅x  - 560⋅x  + 60⋅x  - 1
%% @c doctest: +XFAIL_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% value1 = polyval (sym2poly (C), 0.96105)
%%   @result{} value1 = 0.2219
%% @end group
%% @end example
%% Instead, we could use the present function:
%% @example
%% @group
%% @c doctest: +XFAIL_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% value2 = chebyshevU (10, 0.96105)
%%   @result{} value2 = 0.2219
%% @end group
%% @end example
%% Both results look similar but @code{value2} is more accurate---they
%% differ by significantly more than machine precision:
%% @example
%% @group
%% value1 - value2
%%   @result{} 1.0586e-13
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{chebyshevu}.
%%
%% Developer note: would likely be faster if implemented directly
%% using the three-term recurrence.
%%
%% @seealso{@@double/chebyshevT, @@sym/chebychevU}
%% @end defun


function y = chebyshevU (n, x)
  if (nargin ~= 2)
    print_usage ();
  end

  if (isequal (size (n), size (x)) || isscalar(n))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size (n));
  else
    error ('chebyshevU: inputs N and X must have compatible sizes')
  end

  cmd = { 'Ln = _ins[0]'
          'Lx = _ins[1]'
          'if len(Ln) == 1 and len(Lx) != 1:'
          '    Ln = Ln*len(Lx)'
          'if len(Ln) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Ln)'
          'c = [complex(mpmath.chebyu(n, x)) for n,x in zip(Ln, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (n(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <sizes> chebyshevU ([1 2], [1 2 3])
%!error <sizes> chebyshevU ([1 2], [1; 2])
%!error <Invalid> chebyshevU (1, 2, 3)
%!error <Invalid> chebyshevU (1)

%!test
%! y = sym(11)/10;
%! t = sym(2);
%! x = 1.1;
%! s = 2;
%! A = chebyshevU (s, x);
%! B = double (chebyshevU (t, y));
%! assert (A, B, -2*eps);

%!test
%! % maple
%! A = 1.661891066691338157;
%! B = chebyshevU (18.1, 0.9);
%! assert (A, B, -3*eps)

%!test
%! % maple, complex inputs>
%! % ChebyshevU(12.1+3.1*I, 0.5+0.2*I);
%! A = 1.046959313670290818 - 0.03386773634958834846*1i;
%! B = chebyshevU (12.1+3.1*i, 0.5+0.2i);
%! assert (A, B, -3*eps);

%!test
%! % maple, matrix inputs
%! A = [2.2543638828875776000  -1.3872651600553574400];
%! B = chebyshevU ([16 17], [0.9 0.8]);
%! assert (A, B, -10*eps);

%!test
%! % x matrix, s scalar
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! t = sym(2);
%! x = double (y);
%! s = 2;
%! A = chebyshevU (s, x);
%! B = double (chebyshevU (t, y));
%! assert (A, B, -eps);

%!test
%! % s matrix, x scalar
%! t = [1 2 sym(pi); exp(sym(1)) 5 6];
%! y = sym(2);
%! s = double (t);
%! x = 2;
%! A = chebyshevU (s, x);
%! B = double (chebyshevU (t, y));
%! assert (A, B, -2*eps);

%!xtest
%! % https://github.com/fredrik-johansson/mpmath/issues/469
%! assert (chebyshevU (4, inf), inf)
%! assert (chebyshevU (4, -inf), inf)
%! assert (chebyshevU (3, inf), inf)
%! assert (chebyshevU (3, -inf), -inf)
