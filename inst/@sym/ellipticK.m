%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym ellipticK (@var{m})
%% Complete elliptic integral of the first kind.
%%
%% Example:
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
%%       ⎮          1
%%       ⎮ ──────────────────── dα
%%       ⎮    _________________
%%       ⎮   ╱        2
%%       ⎮ ╲╱  - m⋅sin (α) + 1
%%       ⌡
%%       0
%% @end group
%%
%% @group
%% double (ellipticK (sym (pi)/4))
%%   @result{} ans =  2.2253
%% @end group
%% @end example
%%
%% @seealso{@@sym/ellipticF, @@sym/ellipticPi, ellipKE}
%% @end defmethod


function y = ellipticK(m)
  if nargin > 1
    print_usage();
  end

% y = ellipticF (sym (pi)/2, m);
  y = elementwise_op ('elliptic_k', m);

end


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
%! m = -10.3;
%! ms = -sym(103)/10;
%! [K, E] = ellipke (m);
%! assert (double (ellipticK (ms)), K, -1e-15)
%! assert (double (ellipticE (ms)), E, -1e-15)
