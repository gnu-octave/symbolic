%% Copyright (C) 2015, 2016 Colin B. Macdonald
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
%% @defmethod @@sym nchoosek (@var{n}, @var{k})
%% Symbolic binomial coefficient.
%%
%% Examples:
%% @example
%% @group
%% syms n k
%% nchoosek(n, k)
%%   @result{} ans = (sym)
%%       ⎛n⎞
%%       ⎜ ⎟
%%       ⎝k⎠
%%
%% nchoosek(101, k)
%%   @result{} ans = (sym)
%%       ⎛101⎞
%%       ⎜   ⎟
%%       ⎝ k ⎠
%%
%% nchoosek(sym(1001), sym(25))
%%   @result{} (sym) 48862197129890117991367706991027565961778719519790
%% @end group
%% @end example
%%
%% @seealso{@@sym/factorial}
%% @end defmethod


function C = nchoosek(n, k)

  if (~isscalar(n))
    error('nchoosek: set input for n not implemented');
  end
  assert (isscalar(k), 'nchoosek: k must be scalar');

  C = python_cmd ('return sp.binomial(*_ins),', sym(n), sym(k));

end


%!assert (isequal (nchoosek(sym(5), sym(2)), sym(10)))
%!assert (isequal (nchoosek(sym(5), 2), sym(10)))
%!assert (isequal (nchoosek(5, sym(2)), sym(10)))

%!assert (isequal (nchoosek(sym(10), 0), 1))
%!assert (isequal (nchoosek(sym(10), -1), 0))

%!test
%! n = sym('n', 'integer');
%! q = nchoosek(n, 2);
%! w = subs(q, n, 5);
%! assert (isequal (w, 10))

%!test
%! n = sym('n', 'integer');
%! k = sym('k', 'integer');
%! q = nchoosek(n, k);
%! w = subs(q, {n k}, {5 2});
%! assert (isequal (w, 10))
