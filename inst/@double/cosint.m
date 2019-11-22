%% Copyright (C) 2016-2017, 2019 Colin B. Macdonald
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
%% @defun cosint (@var{x})
%% Numerical cosint function.
%%
%% Example:
%% @example
%% @group
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% cosint (1.1)
%%   @result{} ans = 0.3849
%% @end group
%% @end example
%%
%% @strong{Note} this function may be slow for large numbers of inputs.
%% This is because it is not a native double-precision implementation
%% but rather the numerical evaluation of the Python @code{mpmath} function
%% @code{ci}.
%%
%% Note: this file is autogenerated: if you want to edit it, you might
%% want to make changes to 'generate_functions.py' instead.
%%
%% @seealso{@@sym/cosint}
%% @end defun


function y = cosint (x)
  if (nargin ~= 1)
    print_usage ();
  end
  cmd = { 'L = _ins[0]'
          'A = [complex(mpmath.ci(x)) for x in L]'
          'return A,' };
  c = pycall_sympy__ (cmd, num2cell (x(:)));
  y = reshape (cell2mat (c), size (x));
end


%!test
%! x = 1.1;
%! y = sym(11)/10;
%! A = cosint (x);
%! B = double (cosint (y));
%! assert (A, B, -4*eps);

%!test
%! y = [2 3 sym(pi); exp(sym(1)) 5 6];
%! x = double (y);
%! A = cosint (x);
%! B = double (cosint (y));
%! assert (A, B, -4*eps);

%!test
%! % maple:
%! % > A := [1+2*I, -2 + 5*I, 100, 10*I, -1e-4 + 1e-6*I, -20 + I];
%! % > for a in A do evalf(Ci(a)) end do;
%! x = [1+2i; -2+5i; 100; 10i; -1e-4 + 1e-6*1i; -20-1i];
%! A = [ 2.0302963932917216378 - 0.15190715517585688438*1i
%!       1.6153896382910774851 + 19.725754055338264980*1i
%!      -0.0051488251426104921444
%!       1246.1144860424544147 + 1.5707963267948966192*1i
%!      -8.6330747120742332203 + 3.1315929869531280002*1i
%!       0.069822228467306149311 - 3.1184744625477294643*1i ];
%! B = cosint (x);
%! assert (A, B, -eps)

%!xtest
%! % is it nan or -inf?  SymPy says zoo.
%! assert (isnan (cosint (0)))

% could relax to within eps
%!assert (cosint (inf), 0)
%!assert (cosint (-inf), pi*1i, -eps)

%!assert (cosint (1), 0.33740392290096813466, -eps)
%!assert (cosint (-1), 0.33740392290096813466 + pi*1i, -eps)
%!assert (cosint (pi), 0.073667912046425485978, -5*eps)
%!assert (cosint (-pi), 0.07366791204642548597821 + pi*1i, -5*eps)

%!assert (cosint (300), -3.3321999185921117800e-3, -2*eps)
%!assert (cosint (1e4), -3.0551916724485212665e-5, -2*eps)

%!assert (cosint (1 + 1i), 0.8821721805559363250506+0.2872491335199559395273*1i, eps)

%!assert (cosint (1i), 0.8378669409802082408947 + pi/2*1i, -2*eps)

%!test
%! % compare both sinint and cosint to expint
%! x = pi;
%! C1 = cosint (x);
%! S1 = sinint (x);
%! R = expint (1i*x);
%! C2 = -real (R);
%! S2 = imag (R) + pi/2;
%! assert (C1, C2, -100*eps);
%! assert (S1, S2, -100*eps);
