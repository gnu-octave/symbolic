%% Copyright (C) 2015 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{s} =} dot (@var{a}, @var{b})
%% Symbolic dot (scalar) product.
%%
%% Examples:
%% @example
%% @group
%% a = [sym('a1'); sym('a2'); sym('a3')];
%% b = [sym('b1'); sym('b2'); sym('b3')];
%% dot(a, b)
%%    @result{} (sym) a₁⋅b₁ + a₂⋅b₂ + a₃⋅b₃
%% dot(a, a)
%%    @result{} (sym)
%%         2     2     2
%%       a₁  + a₂  + a₃
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x
%% a = [x; 0; 0];
%% b = [0; 0; sym(1)];
%% dot(a, b)
%%    @result{} ans = (sym) 0
%% @end group
%% @end example
%%
%% @seealso{cross}
%% @end deftypefn

function c = dot(a, b)

  % conjugate linear in the 1st slot to match the behavior of @double/dot
  cmd = { 'a, b = _ins'
          'return a.conjugate().dot(b),'
        };

  c = python_cmd (cmd, sym(a), sym(b));

end


%!test
%! a = sym([1; 1; 0]);
%! b = sym([1; 2; 4]);
%! c = dot(a, b);
%! assert (isequal (c, sym(3)))

%!test
%! syms x
%! a = sym([x; 0; 0]);
%! b = sym([0; 1; 0]);
%! c = dot(a, b);
%! assert (isequal (c, sym(0)))

%!test
%! assert (isequal (dot (sym([1 i]), sym([i 2])), sym(-i)))
