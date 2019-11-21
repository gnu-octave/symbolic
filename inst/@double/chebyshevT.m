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
%% @defun chebyshevT (@var{n}, @var{x})
%% Numerically evaluate Chebyshev polynomials of the first kind.
%%
%% Evaluates the Chebyshev polynomial of the first kind of degree
%% @var{n} at the point @var{x}, in double precision.  Both inputs
%% can be arrays but their sizes must be either the same or scalar.
%%
%% Example:
%% @example
%% @group
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% chebyshevT (18, 0.9)
%%   @result{} ans = -0.2614
%% @end group
%% @end example
%%
%% Using this function may be preferable to evaluating the Chebyshev
%% polynomial in monomial form because the latter can give poor
%% accuracy due to numerical instability.
%% See the example in @pxref{@@double/chebyshevU}.
%%
%% This function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{chebyshevt}.
%%
%% @seealso{@@sym/chebychevT, @@double/chebyshevU}
%% @end defun


function y = chebyshevT (n, x)
  if (nargin ~= 2)
    print_usage ();
  end

  if (isequal (size (n), size (x)) || isscalar(n))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size (n));
  else
    error ('chebyshevT: inputs N and X must have compatible sizes')
  end

  cmd = { 'Ln = _ins[0]'
          'Lx = _ins[1]'
          'if len(Ln) == 1 and len(Lx) != 1:'
          '    Ln = Ln*len(Lx)'
          'if len(Ln) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Ln)'
          'c = [complex(mpmath.chebyt(n, x)) for n,x in zip(Ln, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (n(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <sizes> chebyshevT ([1 2], [1 2 3])
%!error <sizes> chebyshevT ([1 2], [1; 2])
%!error <Invalid> chebyshevT (1, 2, 3)
%!error <Invalid> chebyshevT (1)

%!test
%! y = sym(11)/10;
%! t = sym(2);
%! x = 1.1;
%! s = 2;
%! A = chebyshevT (s, x);
%! B = double (chebyshevT (t, y));
%! assert (A, B, -2*eps);

%!test
%! % maple
%! A = -0.304681164165948269030369;
%! B = chebyshevT (18.1, 0.9);
%! assert (A, B, -10*eps)

%!test
%! % maple, complex inputs
%! % ChebyshevT(12.1+3.1*I, 0.5+0.2*I);
%! A = 0.637229289490379273451 - 0.475324703778957991318*1i;
%! B = chebyshevT (12.1+3.1*i, 0.5+0.2i);
%! assert (A, B, -5*eps);

%!test
%! % maple, matrix inputs
%! A = [0.59523064198266880000  0.57727442996887552000];
%! B = chebyshevT ([16 17], [0.9 0.7]);
%! assert (A, B, -10*eps);

%!test
%! % x matrix, s scalar
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! t = sym(2);
%! x = double (y);
%! s = 2;
%! A = chebyshevT (s, x);
%! B = double (chebyshevT (t, y));
%! assert (A, B, -eps);

%!test
%! % s matrix, x scalar
%! t = [1 2 sym(pi); exp(sym(1)) 5 6];
%! y = sym(2);
%! s = double (t);
%! x = 2;
%! A = chebyshevT (s, x);
%! B = double (chebyshevT (t, y));
%! assert (A, B, -eps);

%!xtest
%! % https://github.com/fredrik-johansson/mpmath/issues/469
%! assert (chebyshevT (4, inf), inf)
%! assert (chebyshevT (4, -inf), inf)
%! assert (chebyshevT (3, inf), inf)
%! assert (chebyshevT (3, -inf), -inf)
