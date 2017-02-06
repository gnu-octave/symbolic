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
%% Incomplete elliptic integral of the second kind:
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
%%
%% @group
%% double (ellipticE (sym (1), sym (1)/10))
%%   @result{} ans =  0.98621
%% @end group
%% @end example
%%
%% Complete elliptic integral of the second kind:
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
%%
%% @group
%% double (ellipticE (sym (-pi)/4))
%%   @result{} ans =  1.8443
%% @end group
%% @end example
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
