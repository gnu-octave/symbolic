%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File}  {@var{h} =} times (@var{f}, @var{g})
%% Symbolic function componentwise multiplication (dot*).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = times(f, g)
  [vars, s1, s2] = helper_symfun_binops(f, g);
  h = symfun(s1 .* s2, vars);
end


%!test
%! syms x
%! f(x) = x^2;
%! assert( isa(f .* f, 'symfun'))
%! assert( isa(f .* x, 'symfun'))

%!test
%! syms x
%! f(x) = [x 2*x];
%! h = f.*[x 3];
%! assert( isa(h, 'symfun'))
%! % FIXME: matlab error issue #107
%! %assert( isequal (h.sym, [x^2 6*x]))
%! hsym = h(x);
%! assert( isequal (hsym, [x^2 6*x]))

