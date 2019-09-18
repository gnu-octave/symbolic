%% Copyright (C) 2016-2019 Colin B. Macdonald
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
%% @defun  zeta (@var{x})
%% @defunx zeta (@var{n}, @var{x})
%% Numerical zeta function.
%%
%% Example:
%% @example
%% @group
%% zeta (1.1)
%%   @result{} ans = 10.584
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{zeta}.
%%
%% TODO: The two-argument form is not yet implemented.
%%
%% @seealso{@@sym/zeta}
%% @end defun


function y = zeta (n, x)
  if (nargin ~= 1 && nargin ~= 2)
    print_usage ();
  end

  if (nargin == 1)
    x = n;
    cmd = { 'L = _ins[0]'
            'A = [complex(mpmath.zeta(x)) for x in L]'
            'return A,' };
    c = pycall_sympy__ (cmd, num2cell (x(:)));
    y = reshape (cell2mat (c), size (x));
    return
  end

  error ('zeta: two input arguments not implemented');
end


%!error <Invalid> zeta (1, 2, 3)
%!assert (isnan (zeta (nan)))

%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = zeta (x);
%! B = double (zeta (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 3 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = zeta (x);
%! B = double (zeta (y));
%! assert (A, B, -4*eps);

%!test
%! % maple:
%! % > A := [1+2*I, -2 + 5*I, 100, 10*I, -1e-4 + 1e-6*I, -20 + I];
%! % > for a in A do evalf(Zeta(a)) end do;
%! x = [1+2i; -2+5i; 100; 10i; -1e-4 + 1e-6*1i; -20-1i];
%! A = [  0.59816556976238173670 - 0.35185474521784529050*1i
%!        0.21425967567391921717 + 0.52503846985036050707*1i
%!        1.0
%!        1.7564685929749629608 - 0.10151198543617116894*1i
%!       -0.49990811617645824900 - 0.91873792757763831501e-6*1i
%!        175.09070083717643866 - 71.512541417467273425*1i ];
%! B = zeta (x);
%! assert (A, B, -eps)

%!assert (zeta (inf), 1.0)
