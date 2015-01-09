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
%% @deftypefn  {Function File}  {@var{h} =} minus (@var{f}, @var{g})
%% Subtract one symbolic function from another (-).
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function h = minus(f, g)
  [vars, s1, s2] = helper_symfun_binops(f, g);
  h = symfun(s1 - s2, vars);
end


%!test
%! syms x
%! f(x) = x^2;
%! assert( isa(f - f, 'symfun'))
%! assert( isa(f - x, 'symfun'))

%!test
%! % Octave bug: https://savannah.gnu.org/bugs/?42735
%! syms x
%! f(x) = x^2;
%! g = x^2;
%! s = warning('off', 'OctSymPy:sym:arithmetic:workaround42735');
%! h = x - f;  assert(isa(h, 'symfun') && isequal(h.sym, x - g))
%! h = x + f;  assert(isa(h, 'symfun') && isequal(h.sym, x + g))
%! h = x * f;  assert(isa(h, 'symfun') && isequal(h.sym, x * g))
%! h = x / f;  assert(isa(h, 'symfun') && isequal(h.sym, x / g))
%! h = x ^ f;  assert(isa(h, 'symfun') && isequal(h.sym, x ^ g))
%! h = x .* f; assert(isa(h, 'symfun') && isequal(h.sym, x .* g))
%! h = x ./ f; assert(isa(h, 'symfun') && isequal(h.sym, x ./ g))
%! h = x .^ f; assert(isa(h, 'symfun') && isequal(h.sym, x .^ g))
%! warning(s);

%!test
%! % different variables
%! syms x y
%! f(x) = 2*x;
%! g(y) = sin(y);
%! h = f - g(x);
%! assert( isa(h, 'symfun'))
%! assert( isequal (argnames (h), argnames (f)))
%! assert( isequal (h.sym, 2*x - sin(x)))
%! % and even if rh-sym has a dummy variable:
%! h = f - g(y);
%! assert( isa(h, 'symfun'))
%! assert( isequal (argnames (h), argnames(f)))
%! assert( isequal (h.sym, 2*x - sin(y)))

%!test
%! % different variables, f has more
%! syms x y
%! f(x,y) = 2*x*y;
%! g(y) = sin(y);
%! h = f - g(y) + g(x);
%! assert( isa(h, 'symfun'))
%! assert( isequal (argnames (h), argnames (f)))
%! assert( isequal (h.sym, 2*x*y - sin(y) + sin(x)))
