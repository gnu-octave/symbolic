%% Copyright (C) 2016-2017 Lagu
%% Copyright (C) 2017, 2019 Colin B. Macdonald
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
%% @defmethod @@sym ellipticK (@var{m})
%% Complete elliptic integral of the first kind.
%%
%% The complete elliptic integral of the first kind
%% with parameter @var{m} is defined by:
%% @example
%% @group
%% syms m
%% ellipticK (m)
%%   @result{} ans = (sym) K(m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       π
%%       ─
%%       2
%%       ⌠
%%       ⎮         1
%%       ⎮ ────────────────── dα
%%       ⎮    _______________
%%       ⎮   ╱          2
%%       ⎮ ╲╱  1 - m⋅sin (α)
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%% diff (ellipticK (m), m)
%%   @result{} (sym)
%%       -(1 - m)⋅K(m) + E(m)
%%       ────────────────────
%%           2⋅m⋅(1 - m)
%% @end group
%%
%% @group
%% vpa (ellipticK (sym (pi)/4))
%%   @result{} (sym) 2.2252536839853959577044373301346
%% @end group
%% @end example
%%
%% There are other conventions for the inputs of elliptic integrals,
%% @pxref{@@sym/ellipticF}.
%%
%% @seealso{@@sym/ellipke, @@sym/ellipticF, @@sym/ellipticE, @@sym/ellipticPi}
%% @end defmethod


function y = ellipticK (m)
  if (nargin > 1)
    print_usage ();
  end

  % y = ellipticF (sym (pi)/2, m);
  y = elementwise_op ('elliptic_k', m);

end


%!error <Invalid> ellipticK (sym(1), 2)

%!assert (isequal (ellipticK (sym (0)), sym (pi)/2))
%!assert (isequal (ellipticK (sym (-inf)), sym (0)))

%!assert (double (ellipticK (sym (1)/2)), 1.854074677, 10e-10)
%!assert (double (ellipticK (sym (pi)/4)), 2.225253684, 10e-10)
%!assert (double (ellipticK (sym (-55)/10)), 0.9324665884, 10e-11)

%!test
%! % compare to double ellipke
%! m = 1/5;
%! ms = sym(1)/5;
%! [K, E] = ellipke (m);
%! assert (double (ellipticK (ms)), K, -1e-15)
%! assert (double (ellipticE (ms)), E, -1e-15)

%!test
%! % compare to double ellipke
%! if (exist ('OCTAVE_VERSION', 'builtin'))
%! m = -10.3;
%! ms = -sym(103)/10;
%! [K, E] = ellipke (m);
%! assert (double (ellipticK (ms)), K, -1e-15)
%! assert (double (ellipticE (ms)), E, -1e-15)
%! end

%!test
%! % compare to Maple
%! us = vpa (ellipticK (sym (7)), 40);
%! % > evalf(EllipticK(sqrt(7)), 40);
%! maple = vpa ('0.6168027921799632674669917683443602673441', 40) - ...
%!         vpa ('0.9114898734184488922164103102629560336918j', 40);
%! assert (abs (double (maple - us)), 0, 1e-39)
