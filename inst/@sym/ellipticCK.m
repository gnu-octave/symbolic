%% Copyright (C) 2016-2017 Lagu
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
%% @defmethod @@sym ellipticCK (@var{m})
%% Complementary complete elliptic integral of the first kind.
%%
%% Example:
%% @example
%% @group
%% syms m
%% ellipticCK (m)
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
%% @group
%% double (ellipticCK (sym (1)/2))
%%   @result{} ans =  1.8541
%% @end group
%% @end example
%%
%% @seealso{@@sym/ellipticF, @@sym/ellipticPi}
%% @end defmethod


function y = ellipticCK(m)
  if nargin > 1
    print_usage();
  end

  y = ellipticF (sym (pi)/2, m);

end


%!assert (double (ellipticCK (sym (1)/2)), 1.8541, 10e-5)
