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
%% @deftypefun  bernoulli (@var{n})
%% @deftypefunx bernoulli (@var{n}, @var{x})
%% Numerically evaluate Bernoulli numbers and polynomials.
%%
%% Examples:
%% @example
%% @group
%% bernoulli (6)
%%   @result{} 0.023810
%% bernoulli (7)
%%   @result{} 0
%% @end group
%% @end example
%%
%% Polynomial example:
%% @example
%% @group
%% bernoulli (2, pi)
%%   @result{} 6.8947
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation.
%%
%% @seealso{@@sym/bernoulli}
%% @end deftypefun

function y = bernoulli (m, x)

  if (nargin ~= 1 && nargin ~= 2)
    print_usage ();
  end

  if (nargin == 1)
    x = 0;
  end

  if (isequal (size (m), size (x)) || isscalar (m))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size (m));
  else
    error ('bernoulli: inputs N and X must have compatible sizes')
  end

  cmd = { 'Lm = _ins[0]'
          'Lx = _ins[1]'
          'if len(Lm) == 1 and len(Lx) != 1:'
          '    Lm = Lm*len(Lx)'
          'if len(Lm) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Lm)'
          'c = [complex(mpmath.bernpoly(int(m), x)) for m,x in zip(Lm, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (m(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <usage> bernoulli (1, 2, 3)
%!error <sizes> bernoulli ([1 2], [1 2 3])
%!error <sizes> bernoulli ([1 2], [1; 2])

%!assert (bernoulli (0), 1)
%!assert (bernoulli (3), 0)
%!assert (bernoulli (1), -0.5, -eps)

%!test
%! n = sym(88);
%! m = 88;
%! A = bernoulli (m);
%! B = double (bernoulli (n));
%! assert (A, B, -eps);

%!test
%! m = [0 1; 2 4];
%! n = sym(m);
%! A = bernoulli (m);
%! B = double (bernoulli (n));
%! assert (isequal (A, B));

%!test
%! y = sym(19)/10;
%! n = sym(2);
%! x = 1.9;
%! m = 2;
%! A = bernoulli (m, x);
%! B = double (bernoulli (n, y));
%! assert (A, B, -eps);

%!test
%! assert (isequal (bernoulli (4, inf), inf))
%! assert (isequal (bernoulli (4, -inf), inf))
%!xtest
%! % still broken?
%! assert (isequal (bernoulli (3, inf), inf))
%! assert (isequal (bernoulli (3, -inf), -inf))

%!test
%! assert (isnan (bernoulli(3, nan)))
%! assert (isnumeric (bernoulli(3, nan)))

%!test
%! % maple, complex input
%! A = 34.21957245745810513 - 130.0046256649829101i;
%! B = bernoulli(7, 2.123 + 1.234i);
%! assert (A, B, -5*eps);

%!test
%! % x matrix, m scalar
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! n = sym(2);
%! x = double (y);
%! m = 2;
%! A = bernoulli (m, x);
%! B = double (bernoulli (n, y));
%! assert (A, B, -eps);

%!test
%! % m matrix, x scalar
%! m = [1 2 3; 4 5 6];
%! n = sym(m);
%! y = sym(21)/10;
%! x = 2.1;
%! A = bernoulli (m, x);
%! B = double (bernoulli (n, y));
%! assert (A, B, -3*eps);
