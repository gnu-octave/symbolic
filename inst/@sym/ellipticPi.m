%% Copyright (C) 2016-2017 Lagu
%% Copyright (C) 2017 Colin B. Macdonald
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
%% @defmethod  @@sym y = ellipticPi (@var{nu}, @var{m})
%% @defmethodx @@sym y = ellipticPi (@var{nu}, @var{phi}, @var{m})
%% Complete and incomplete elliptic integrals of the third kind.
%%
%% Incomplete elliptic integral of the third kind with characteristic
%% @var{nu}, amplitude @var{phi} and parameter @var{m}:
%% @example
%% @group
%% syms nu phi m
%% ellipticPi (nu, phi, m)
%%   @result{} (sym) Π(ν; φ│m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       φ
%%       ⌠
%%       ⎮                   1
%%       ⎮ ────────────────────────────────────── dα
%%       ⎮    _________________
%%       ⎮   ╱        2         ⎛       2       ⎞
%%       ⎮ ╲╱  - m⋅sin (α) + 1 ⋅⎝- ν⋅sin (α) + 1⎠
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Complete elliptic integral of the third kind with characteristic
%% @var{nu} and parameter @var{m}:
%% @example
%% @group
%% ellipticPi (nu, m)
%%   @result{} ans = (sym) Π(ν│m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       π
%%       ─
%%       2
%%       ⌠
%%       ⎮                   1
%%       ⎮ ────────────────────────────────────── dα
%%       ⎮    _________________
%%       ⎮   ╱        2         ⎛       2       ⎞
%%       ⎮ ╲╱  - m⋅sin (α) + 1 ⋅⎝- ν⋅sin (α) + 1⎠
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% vpa (ellipticPi (sym (1), sym (1)/10, sym (1)/2))
%%   @result{} (sym) 0.10041852861527457424263837477419
%% @end group
%%
%% @group
%% vpa (ellipticPi (sym (pi)/4, sym (pi)/8))
%%   @result{} (sym) 4.0068172051461721205075153294257
%% @end group
%% @end example
%%
%% There are other conventions for the inputs of elliptic integrals,
%% @pxref{@@sym/ellipticF}.
%%
%% @seealso{@@sym/ellipticF, @@sym/ellipticK, @@sym/ellipticE}
%% @end defmethod


function y = ellipticPi (nu, phi, m)

  switch nargin
    case 2
      y = ellipticPi (nu, sym (pi)/2, phi);
    case 3
      y = elementwise_op ('elliptic_pi', sym (nu), sym (phi), sym (m));
    otherwise
      print_usage();
  end

end


%!error <Invalid> ellipticPi (sym (1))
%!error <Invalid> ellipticPi (sym (1), 2, 3, 4)

%!assert (double (ellipticPi (sym (-23)/10, sym (pi)/4, 0)), 0.5876852228, 10e-11)
%!assert (double (ellipticPi (sym (1)/3, sym (pi)/3, sym (1)/2)), 1.285032276, 10e-11)
%!assert (double (ellipticPi (sym (2), sym (pi)/6, sym (2))), 0.7507322117, 10e-11)

%!xtest
%! % FIXME: search/report upstream
%! assert (double (ellipticPi (sym (-1), 0, sym (1))), 0)

%!test
%! % compare to Maple, complete
%! us = vpa (ellipticPi (sym(1)/6, sym(4)/3), 40);
%! % > evalf(EllipticPi(sin(1/6), sqrt(4/3)), 40);
%! maple = vpa ('2.019271696236161760696477679310987869058', 40) - ...
%!         vpa ('1.708165765120289929280805062355360570830j', 40);
%! assert (abs (double (maple - us)), 0, 2e-39)

%!test
%! % compare to Maple, incomplete
%! us = vpa (ellipticPi (sym(8)/7, sym(4)/3, sym(2)/7), 40);
%! % > evalf(EllipticPi(sin(4/3), 8/7, sqrt(2/7)), 40);
%! maple = vpa ('2.089415796799294830305265090302275542033', 40) - ...
%!         vpa ('4.798862045930802761256228043192491271947j', 40);
%! assert (abs (double (maple - us)), 0, 6e-39)
