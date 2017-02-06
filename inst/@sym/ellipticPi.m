%% Copyright (C) 2016 Lagu
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
%% @defmethod  @@sym y = ellipticPi (@var{n}, @var{m})
%% @defmethodx @@sym y = ellipticPi (@var{n}, @var{phi}, @var{m})
%% Complete and incomplete elliptic integrals of the third kind.
%%
%% Incomplete elliptic integral of the third kind:
%% @example
%% @group
%% syms n phi m
%% ellipticPi (n, phi, m)
%%   @result{} (sym) Π(n; φ│m)
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
%%       ⎮ ╲╱  - m⋅sin (α) + 1 ⋅⎝- n⋅sin (α) + 1⎠
%%       ⌡
%%       0
%% @end group
%%
%% @group
%% double (ellipticPi (sym (1), sym (1)/10, sym (1)/2))
%%   @result{} ans =  0.10042
%% @end group
%% @end example
%%
%% Complete elliptic integral of the third kind:
%% @example
%% @group
%% syms n m
%% ellipticPi (n, m)
%%   @result{} ans = (sym) Π(n│m)
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
%%       ⎮ ╲╱  - m⋅sin (α) + 1 ⋅⎝- n⋅sin (α) + 1⎠
%%       ⌡
%%       0
%% @end group
%%
%% @group
%% double (ellipticPi (sym (pi)/4, sym (pi)/8))
%%   @result{} ans =  4.0068
%% @end group
%% @end example
%%
%% @seealso{@@sym/ellipticF, @@sym/ellipticK, @@sym/ellipticE}
%% @end defmethod


function y = ellipticPi(n, phi, m)

  switch nargin
    case 2
      y = ellipticPi (n, sym (pi)/2, phi);
    case 3
      y = elementwise_op ('elliptic_pi', sym (n), sym (phi), sym (m));
    otherwise
      print_usage();
  end

end


%!error <Invalid> ellipticPi (sym (1))
%!error <Invalid> ellipticPi (sym (1), 2, 3, 4)

%!assert (double (ellipticPi (sym (-23)/10, sym (pi)/4, 0)), 0.5876852228, 10e-11)
%!assert (double (ellipticPi (sym (1)/3, sym (pi)/3, sym (1)/2)), 1.285032276, 10e-11)
%!xtest assert (double (ellipticPi (sym (-1), 0, sym (1))), 0)
%!assert (double (ellipticPi (sym (2), sym (pi)/6, sym (2))), 0.7507322117, 10e-11)
