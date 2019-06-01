%% Copyright (C) 2016-2017, 2019 Colin B. Macdonald
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
%% @defmethod  @@sym hypergeom (@var{a}, @var{b}, @var{z})
%% Symbolic generalized hypergeometric function.
%%
%% Example:
%% @example
%% @group
%% syms z
%% hypergeom ([1, 2, 3], [4, 5], z)
%%   @result{} (sym)
%%        ┌─  ⎛1, 2, 3 │  ⎞
%%        ├─  ⎜        │ z⎟
%%       3╵ 2 ⎝  4, 5  │  ⎠
%% @end group
%% @end example
%%
%% Simplifying can be useful to express a hypergeometric
%% function in terms of more elementary functions:
%% @example
%% @group
%% simplify (hypergeom ([1 1], 2, -z))
%%   @result{} (sym)
%%       log(z + 1)
%%       ──────────
%%           z
%% @end group
%% @end example
%%
%% The function can be `vectorized' over @var{z}:
%% @example
%% @group
%% syms a b c
%% hypergeom([a b], c, [z 1/z 8])
%%   @result{} (sym 1×3 matrix)
%%       ⎡ ┌─  ⎛a, b │  ⎞   ┌─  ⎛a, b │ 1⎞   ┌─  ⎛a, b │  ⎞⎤
%%       ⎢ ├─  ⎜     │ z⎟   ├─  ⎜     │ ─⎟   ├─  ⎜     │ 8⎟⎥
%%       ⎣2╵ 1 ⎝ c   │  ⎠  2╵ 1 ⎝ c   │ z⎠  2╵ 1 ⎝ c   │  ⎠⎦
%% @end group
%% @end example
%%
%% The hypergeometric function can be differentiated, for example:
%% @example
%% @group
%% w = hypergeom([a b], c, z)
%%   @result{} w = (sym)
%%        ┌─  ⎛a, b │  ⎞
%%        ├─  ⎜     │ z⎟
%%       2╵ 1 ⎝ c   │  ⎠
%%
%% diff(w, z)
%%   @result{} (sym)
%%            ┌─  ⎛a + 1, b + 1 │  ⎞
%%       a⋅b⋅ ├─  ⎜             │ z⎟
%%           2╵ 1 ⎝   c + 1     │  ⎠
%%       ───────────────────────────
%%                    c
%% @end group
%% @end example
%% @end defmethod

function F = hypergeom(a, b, z)

  if (nargin ~= 3)
    print_usage ();
  end

  cmd = { '(a, b, z) = _ins'
          'try:'
          '   iter(a)'
          'except TypeError:'
          '   a = [a]'
          'try:'
          '   iter(b)'
          'except TypeError:'
          '   b = [b]'
          'if z.is_Matrix:'
          '    return z.applyfunc(lambda x: hyper(a, b, x))'
          'return hyper(a, b, z)' };

  F = pycall_sympy__ (cmd, sym(a), sym(b), sym(z));

end


%!assert (isequal (double (hypergeom ([1, 2], [2, 3], sym(0))), 1))

%!test
%! % matrix input
%! syms z
%! a = sym([1 2]);
%! b = sym([3 4]);
%! A = hypergeom (a, b, [0 sym(1); 2 z]);
%! B = [hypergeom(a,b,0) hypergeom(a,b,1); hypergeom(a,b,2) hypergeom(a,b,z)];
%! assert (isequal (A, B))

%!test
%! % scalars for a and/or b
%! syms z
%! assert (isequal (hypergeom(1, 2, z), hypergeom({sym(1)}, {sym(2)}, z)))
%! assert (isequal (hypergeom([1 2], 3, z), hypergeom([1 2], {sym(3)}, z)))
%! assert (isequal (hypergeom(1, [2 3], z), hypergeom({sym(1)}, [2 3], z)))
