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
%% @defmethod @@sym ellipticF (@var{phi}, @var{m})
%% Incomplete elliptic integral of the first kind.
%%
%% Example:
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
%% @group
%% double (ellipticF (sym (1), sym (-1)))
%%   @result{} ans =  0.89639
%% @end group
%% @end example
%%
%% @seealso{@@sym/ellipticPi}
%% @end defmethod


function y = ellipticF(phi, m)

  if nargin ~= 2
    print_usage ();
  end

% y = ellipticPi (0, phi, m);
  y = elementwise_op ('elliptic_f', phi, m);

end


%!assert (double (ellipticF (sym (pi)/3, sym (-105)/10)), 0.6184459461, 10e-11)
%!assert (double (ellipticF (sym (pi)/4, sym (-pi))), 0.6485970495, 10e-11)
%!assert (double (ellipticF (sym (1), sym (-1))), 0.8963937895, 10e-11)
%!assert (double (ellipticF (sym (pi)/6, sym (0))), 0.5235987756, 10e-11)
