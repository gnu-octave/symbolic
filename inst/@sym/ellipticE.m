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
%% @defmethod  @@sym ellipticE (@var{m})
%% @defmethodx @@sym ellipticE (@var{phi}, @var{m})
%% Complete and incomplete elliptic integrals of the second kind.
%%
%% The incomplete elliptic integral of the second kind with
%% amplitude @var{phi} and parameter @var{m} is given by:
%% @example
%% @group
%% syms phi m
%% ellipticE (phi, m)
%%   @result{} ans = (sym) E(φ│m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       φ
%%       ⌠
%%       ⎮    _________________
%%       ⎮   ╱        2
%%       ⎮ ╲╱  - m⋅sin (α) + 1  dα
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% The complete elliptic integral of the second kind with
%% parameter @var{m} is given by:
%% @example
%% @group
%% ellipticE (m)
%%   @result{} ans = (sym) E(m)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       π
%%       ─
%%       2
%%       ⌠
%%       ⎮    _________________
%%       ⎮   ╱        2
%%       ⎮ ╲╱  - m⋅sin (α) + 1  dα
%%       ⌡
%%       0
%% @end group
%% @end example
%%
%% Examples:
%% @example
%% @group
%% vpa (ellipticE (sym (1), sym (1)/10))
%%   @result{} (sym) 0.98620694978157550636951680164874
%% @end group
%%
%% @group
%% vpa (ellipticE (sym (-pi)/4))
%%   @result{} (sym) 1.8443492468732292114663773247580
%% @end group
%% @end example
%%
%% There are other conventions for the inputs of elliptic integrals,
%% @pxref{@@sym/ellipticF}.
%%
%% @seealso{@@sym/ellipke, @@sym/ellipticK, @@sym/ellipticPi}
%% @end defmethod


function y = ellipticE (phi, m)

  if (nargin == 1)
    m = phi;
    phi = sym (pi)/2;
  elseif (nargin == 2)
    % no-op
  else
    print_usage ();
  end

  y = elementwise_op ('elliptic_e', sym (phi), sym (m));

end


%!error <Invalid> ellipticE (sym(1), 2, 3)

%!assert (double (ellipticE (sym (-105)/10)), 3.70961391, 10e-9)
%!assert (double (ellipticE (sym (-pi)/4)), 1.844349247, 10e-10)
%!assert (double (ellipticE (sym (0))), 1.570796327, 10e-10)
%!assert (double (ellipticE (sym (1))), 1, 10e-1)

%!test
%! % compare to Maple
%! us = vpa (ellipticE (sym(7)/6, sym(13)/7), 40);
%! % > evalf(EllipticE(sin(7/6), sqrt(13/7)), 40);
%! maple = vpa ('0.6263078268598504591831743625971763209496', 40) + ...
%!         vpa ('0.1775496232203171126975790989055865596501j', 40);
%! assert (abs (double (maple - us)), 0, 2e-39)

%!test
%! % compare to Maple
%! us = vpa (ellipticE (sym(8)/7), 40);
%! % > evalf(EllipticE(sqrt(8/7)), 40);
%! maple = vpa ('0.8717182992576322508542205614105802333270', 40) + ...
%!         vpa ('0.1066754320328976949531350910798010526685j', 40);
%! assert (abs (double (maple - us)), 0, 2e-39)
