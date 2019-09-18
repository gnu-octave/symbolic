%% Copyright (C) 2017-2019 Colin B. Macdonald
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
%% @deftypefun  euler (@var{m})
%% @deftypefunx euler (@var{m}, @var{x})
%% Numerical Euler numbers or Euler polynomials.
%%
%% Examples:
%% @example
%% @group
%% euler (0)
%%   @result{} 1
%% euler (32)
%%   @result{} 1.7752e+29
%% @end group
%% @end example
%%
%% Polynomial example:
%% @example
%% @group
%% euler (2, pi)
%%   @result{} 6.7280
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation.
%%
%% @seealso{@@sym/euler}
%% @end deftypefun

function y = euler (m, x)

  if (nargin ~= 1 && nargin ~= 2)
    print_usage ();
  end

  if (nargin == 1)
    y = zeros (size (m));
    cmd = { 'return [float(euler(sp.Integer(m))) for m in _ins[0]],' };
    c = pycall_sympy__ (cmd, num2cell (m(:)));
    for i = 1:numel (c)
      y(i) = c{i};
    end
    return
  end

  if (isequal (size (m), size (x)) || isscalar (m))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size (m));
  else
    error ('euler: inputs M and X must have compatible sizes')
  end

  cmd = { 'Lm = _ins[0]'
          'Lx = _ins[1]'
          'if len(Lm) == 1 and len(Lx) != 1:'
          '    Lm = Lm*len(Lx)'
          'if len(Lm) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Lm)'
          'c = [complex(mpmath.eulerpoly(int(m), x)) for m,x in zip(Lm, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (m(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <usage> euler (1, 2, 3)
%!error <sizes> euler ([1 2], [1 2 3])
%!error <sizes> euler ([1 2], [1; 2])

%!assert (isequal (euler (0), 1))
%!assert (isequal (euler (1), 0))
%!assert (isequal (euler (10), -50521))

%!test
%! n = sym(88);
%! m = 88;
%! A = euler (m);
%! B = double (euler (n));
%! assert (A, B, -eps);

%!test
%! m = [0 1; 2 4];
%! n = sym(m);
%! A = euler (m);
%! B = double (euler (n));
%! assert (isequal (A, B));

%!test
%! y = sym(19)/10;
%! n = sym(2);
%! x = 1.9;
%! m = 2;
%! A = euler (m, x);
%! B = double (euler (n, y));
%! assert (A, B, -eps);

%!test
%! % correct behaviour at floating point infinity
%! assert (isequal (euler (4, inf), inf))
%! assert (isequal (euler (4, -inf), inf))
%! assert (isequal (euler (3, inf), inf))
%! assert (isequal (euler (3, -inf), -inf))

%!test
%! assert (isnan (euler(3, nan)))
%! assert (isnumeric (euler(3, nan)))

%!test
%! % maple, complex input
%! A = 113.33970046079423204 - 46.991080726974811540i;
%! B = euler(7, 2.12345 + 1.23i);
%! assert (A, B, -eps);

%!test
%! % maple, complex input, large m, small x
%! A = 0.18034673393294025238e276 + 0.27756266681280689172e276*i;
%! B = euler (200, 0.123+0.234i);
%! assert (A, B, -eps);

%!test
%! % x matrix, m scalar
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! n = sym(2);
%! x = double (y);
%! m = 2;
%! A = euler (m, x);
%! B = double (euler (n, y));
%! assert (A, B, -eps);

%!test
%! % m matrix, x scalar
%! m = [1 2 3; 4 5 6];
%! n = sym(m);
%! y = sym(21)/10;
%! x = 2.1;
%! A = euler (m, x);
%! B = double (euler (n, y));
%! assert (A, B, -3*eps);
