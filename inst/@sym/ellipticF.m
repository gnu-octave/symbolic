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
%% @defmethod @@sym ellipticF (@var{phi}, @var{m})
%% Incomplete elliptic integral of the first kind.
%%
%% The incomplete elliptic integral of the first kind with
%% amplitude @var{phi} and parameter @var{m} is given by:
%% @example
%% @group
%% syms phi m
%% ellipticF (phi, m)
%%   @result{} ans = (sym) F(φ│m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       φ
%%       ⌠
%%       ⎮          1
%%       ⎮ ──────────────────── dα
%%       ⎮    _________________
%%       ⎮   ╱        2
%%       ⎮ ╲╱  - m⋅sin (α) + 1
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Example:
%% @example
%% @group
%% vpa (ellipticF (sym (1), sym (-1)))
%%   @result{} (sym) 0.89639378946289458637047451642060
%% @end group
%% @end example
%%
%% For the complete elliptic integral (of the first kind), @pxref{@@sym/ellipticK}.
%%
%% @strong{Note:}
%% this function (and other elliptic integrals in the Symbolic package)
%% follow the Abramowitz and Stegun convention for the ``parameter''
%% @iftex
%% @math{m}.
%% @end iftex
%% @ifnottex
%% @var{m}.
%% @end ifnottex
%% Other sources and software may use different conventions, such as
%% @iftex
%% the ``elliptic modulus'' @math{k}
%% or the ``modular angle'' @math{\alpha},
%% related by @math{m = k^2 = \sin^2(\alpha)}.
%% @end iftex
%% @ifnottex
%% the ``elliptic modulus'' k
%% or the ``modular angle'' α,
%% related by @code{@var{m} = k^2 = sin^2(α)}.
%% @end ifnottex
%% They may define these functions in terms of the sine of the amplitude
%% @iftex
%% @math{\sin(\phi)}.
%% @end iftex
%% @ifnottex
%% @code{sin(@var{phi})}.
%% @end ifnottex
%% For example, Maple uses the elliptic modulus and the sine of the amplitude.
%%
%% @seealso{@@sym/ellipticK, @@sym/ellipticE, @@sym/ellipticPi}
%% @end defmethod


function y = ellipticF (phi, m)

  if (nargin ~= 2)
    print_usage ();
  end

  % y = ellipticPi (0, phi, m);
  y = elementwise_op ('elliptic_f', sym (phi), sym (m));

end


%!error <Invalid> ellipticF (sym(1))
%!error <Invalid> ellipticF (sym(1), 2, 3)

%!assert (double (ellipticF (sym (pi)/3, sym (-105)/10)), 0.6184459461, 10e-11)
%!assert (double (ellipticF (sym (pi)/4, sym (-pi))), 0.6485970495, 10e-11)
%!assert (double (ellipticF (sym (1), sym (-1))), 0.8963937895, 10e-11)
%!assert (double (ellipticF (sym (pi)/6, sym (0))), 0.5235987756, 10e-11)

%!test
%! % compare to Maple
%! us = vpa (ellipticF (sym(11)/10, sym(9)/4), 40);
%! % > evalf(EllipticF(sin(11/10), sqrt(9/4)), 40);
%! maple = vpa ('1.206444996991058996424988192917728014427', 40) - ...
%!         vpa ('0.8157358125823472313001683083685348517476j', 40);
%! assert (abs (double (maple - us)), 0, 1e-39)
