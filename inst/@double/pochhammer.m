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
%% @defun pochhammer (@var{x}, @var{n})
%% Numerically evaluate the Rising Factorial or Pochhammer symbol.
%%
%% Example:
%% @example
%% @group
%% pochhammer (18, 0.9)
%%   @result{} ans = 13.448
%% @end group
%% @end example
%%
%% @seealso{@@sym/pochhammer}
%% @end defun


function y = pochhammer (n, x)
  if (nargin ~= 2)
    print_usage ();
  end

  if (isequal (size (n), size (x)) || isscalar(n))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size (n));
  else
    error ('pochhammer: inputs N and X must have compatible sizes')
  end

  cmd = { 'Ln = _ins[0]'
          'Lx = _ins[1]'
          'if len(Ln) == 1 and len(Lx) != 1:'
          '    Ln = Ln*len(Lx)'
          'if len(Ln) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Ln)'
          'c = [complex(mpmath.rf(n, x)) for n,x in zip(Ln, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (n(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <sizes> pochhammer ([1 2], [1 2 3])
%!error <sizes> pochhammer ([1 2], [1; 2])
%!error <Invalid> pochhammer (1, 2, 3)
%!error <Invalid> pochhammer (1)

%!test
%! y = sym(11)/10;
%! t = sym(3);
%! x = 1.1;
%! s = 3;
%! A = pochhammer (x, s);
%! B = double (pochhammer (y, t));
%! assert (A, B, -2*eps);

%!test
%! % maple
%! A = 256.798558090310131720;
%! B = pochhammer (18.1, 1.9);
%! assert (A, B, -20*eps)

%!test
%! % maple, complex inputs>
%! A = 2.67921619474318221972 + 1.96716724764630702653*1i;
%! B = pochhammer (12.1+3.1*i, 0.5+0.2i);
%! assert (A, B, -4*eps);

%!test
%! % maple, matrix inputs
%! A = [5.61467232547723663908 20.6144884613920190965];
%! B = pochhammer ([0.9 0.8], [3.1 4.2]);
%! assert (A, B, -3*eps);

%!test
%! % x matrix, s scalar
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! t = sym(2);
%! x = double (y);
%! s = 2;
%! A = pochhammer (s, x);
%! B = double (pochhammer (t, y));
%! assert (A, B, -3*eps);
%! end

%!test
%! % s matrix, x scalar
%! t = [1 2 sym(pi); exp(sym(1)) 5 6];
%! y = sym(2);
%! s = double (t);
%! x = 2;
%! A = pochhammer (s, x);
%! B = double (pochhammer (t, y));
%! assert (A, B, -5*eps);
