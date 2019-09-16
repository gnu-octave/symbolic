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
%% @defun polylog (@var{s}, @var{z})
%% Numerical polylogarithm function
%%
%% Evaluates the polylogarithm of order @var{s} and argument @var{z},
%% in double precision.  Both inputs can be arrays but their sizes
%% must be either the same or scalar.
%%
%% Example:
%% @example
%% @group
%% polylog (2, -4)
%%   @result{} ans = -2.3699
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{polylog}.
%%
%% @seealso{@@sym/polylog}
%% @end defun


function y = polylog (s, x)
  if (nargin ~= 2)
    print_usage ();
  end

  if (isequal (size (s), size (x)) || isscalar(s))
    y = zeros (size (x));
  elseif (isscalar (x))
    y = zeros (size( s));
  else
    error ('polylog: inputs S and X must have compatible sizes')
  end

  cmd = { 'Ls = _ins[0]'
          'Lx = _ins[1]'
          'if len(Ls) == 1 and len(Lx) != 1:'
          '    Ls = Ls*len(Lx)'
          'if len(Ls) != 1 and len(Lx) == 1:'
          '    Lx = Lx*len(Ls)'
          'c = [complex(polylog(s, x)) for s,x in zip(Ls, Lx)]'
          'return c,' };
  c = pycall_sympy__ (cmd, num2cell (s(:)), num2cell (x(:)));
  for i = 1:numel (c)
    y(i) = c{i};
  end
end


%!error <sizes> polylog ([1 2], [1 2 3])
%!error <sizes> polylog ([1 2], [1; 2])
%!error <Invalid> polylog (1, 2, 3)
%!error <Invalid> polylog (1)

%!test
%! y = sym(11)/10;
%! t = sym(2);
%! x = 1.1;
%! s = 2;
%! A = polylog (s, x);
%! B = double (polylog (t, y));
%! assert (A, B, -eps);

%!test
%! % maple
%! A = 2.3201804233130983964 - 3.4513922952232026614*1i;
%! B = polylog (2, 3);
%! assert (A, B, -eps)

%!test
%! % maple, complex inputs
%! A = -11.381456201167411758 + 6.2696695219721651947*1i;
%! B = polylog (1+2i, 3+4i);
%! assert (A, B, -eps);

%!test
%! % maple, matrix inputs
%! A1 = 0.47961557317612748431 - 0.52788287823025778869*1i;
%! A2 = -0.0049750526563452645369 - 0.024579343612396884851*1i;
%! B = polylog ([-1-2i -3], [30+40i 40i]);
%! assert ([A1 A2], B, -eps);

%!test
%! % x matrix, s scalar
%! y = [1 2 sym(pi); exp(sym(1)) 5 6];
%! t = sym(2);
%! x = double (y);
%! s = 2;
%! A = polylog (s, x);
%! B = double (polylog (t, y));
%! assert (A, B, -eps);

%!test
%! % s matrix, x scalar
%! t = [1 2 sym(pi); exp(sym(1)) 5 6];
%! y = sym(2);
%! s = double (t);
%! x = 2;
%! A = polylog (s, x);
%! B = double (polylog (t, y));
%! assert (A, B, -eps);
