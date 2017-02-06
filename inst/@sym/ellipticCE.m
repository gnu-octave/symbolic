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
%% @defmethod @@sym ellipticCE (@var{m})
%% Complementary complete elliptic integral of the second kind.
%%
%% Example:
%% @example
%% @group
%% syms m
%% ellipticCE (m)
%%   @result{} ans = (sym) E(-m + 1)
%% @end group
%%
%% @group
%% rewrite (ans, 'Integral')         % doctest: +SKIP
%%   @result{} ans = (sym)
%%       π
%%       ─
%%       2
%%       ⌠
%%       ⎮    ________________________
%%       ⎮   ╱               2
%%       ⎮ ╲╱  - (-m + 1)⋅sin (α) + 1  dα
%%       ⌡
%%       0
%% @end group
%% @group
%% double (ellipticCE (sym (pi)/4))
%%   @result{} ans =  1.4828
%% @end group
%% @end example
%%
%% @seealso{@@sym/ellipticE}
%% @end defmethod


function y = ellipticCE(m)
  if nargin > 1
    print_usage();
  end

  y = ellipticE (sym (pi)/2, 1 - m);

end


%!assert (double (ellipticCE (sym (0))), 1)
%!assert (double (ellipticCE (sym (pi)/4)), 1.482786927, 10e-10)
%!assert (double (ellipticCE (sym (1))), 1.570796327, 10e-10)
%!assert (double (ellipticCE (sym (pi)/2)), 1.775344699, 10e-1)
