%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod  @@sym heaviside (@var{x})
%% @defmethodx @@sym heaviside (@var{x}, @var{zero_value})
%% Symbolic Heaviside step function.
%%
%% Example:
%% @example
%% @group
%% syms x
%% y = heaviside(x)
%%   @result{} y = (sym) Heaviside(x)
%% @end group
%% @end example
%%
%% By default, the value at zero is undefined:
%% @example
%% @group
%% heaviside(sym(0))
%%   @result{} (sym) Heaviside(0)
%% @end group
%% @end example
%% This behaviour is different from the double-precision function:
%% @example
%% @group
%% heaviside(0)
%%   @result{} 0.50000
%% @end group
%% @end example
%% (@pxref{heaviside})
%%
%% The optional second argument overrides the default:
%% @example
%% @group
%% @comment Needs SymPy > 1.0
%% @c doctest: +XFAIL_IF(python_cmd('return Version(spver) <= Version("1.0")'))
%% heaviside(0, sym(1)/2)
%%   @result{} (sym) 1/2
%% @c doctest: +XFAIL_IF(python_cmd('return Version(spver) <= Version("1.0")'))
%% heaviside(0, [0 sym(1)/2 10])
%%   @result{} (sym) [0  1/2  10]  (1×3 matrix)
%% @end group
%% @end example
%% (As of June 2016, this requires a development release of SymPy).
%%
%% @seealso{heaviside, @@sym/dirac}
%% @end defmethod


function y = heaviside(x, h0)
  if (nargin == 1)
    y = uniop_helper (x, 'Heaviside');
  elseif (nargin == 2)
    y = binop_helper (x, h0, 'Heaviside');
  else
    print_usage ();
  end
end


%!error <Invalid> heaviside (sym(1), 2, 3)

%!assert (isequal (heaviside (sym(1)), sym(1)))
%!assert (isequal (heaviside (-sym(1)), sym(0)))

%!assert (double (heaviside (1)), heaviside (1))

%!test
%! D = [1 -1; -10 20];
%! A = sym(D);
%! assert (double (heaviside (A)), heaviside (D))

%!test
%! if (python_cmd ('return Version(spver) <= Version("1.0")'))
%! print ('skipping test, sympy too old')
%! else
%! H0 = sym([1 -2 0; 3 0 pi]);
%! A = heaviside (sym(0), H0);
%! assert (isequal (A, H0))
%! end

%!test
%! if (python_cmd ('return Version(spver) <= Version("1.0")'))
%! print ('skipping test, sympy too old')
%! else
%! A = heaviside ([-1 0 1], sym(1)/2);
%! assert (isequal (A, [0 sym(1)/2 1]))
%! end
