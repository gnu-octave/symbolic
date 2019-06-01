%% Copyright (C) 2015, 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym cross (@var{a}, @var{b})
%% Symbolic cross product.
%%
%% Examples:
%% @example
%% @group
%% a = [sym('a1'); sym('a2'); sym('a3')];
%% b = [sym('b1'); sym('b2'); sym('b3')];
%% cross(a, b)
%%   @result{} (sym 3×1 matrix)
%%       ⎡a₂⋅b₃ - a₃⋅b₂ ⎤
%%       ⎢              ⎥
%%       ⎢-a₁⋅b₃ + a₃⋅b₁⎥
%%       ⎢              ⎥
%%       ⎣a₁⋅b₂ - a₂⋅b₁ ⎦
%%
%% cross(a, a)
%%   @result{} (sym 3×1 matrix)
%%       ⎡0⎤
%%       ⎢ ⎥
%%       ⎢0⎥
%%       ⎢ ⎥
%%       ⎣0⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/dot}
%% @end defmethod


function c = cross(a, b)

  if (nargin ~= 2)
    print_usage ();
  end

  cmd = { 'a, b = _ins'
          'return a.cross(b),'
        };

  c = pycall_sympy__ (cmd, sym(a), sym(b));

end


%!error <Invalid> cross (sym(1), 2, 3)

%!test
%! a = sym([1; 0; 0]);
%! b = sym([0; 1; 0]);
%! c = cross(a, b);
%! assert (isequal (c, sym([0; 0; 1])))

%!test
%! syms x
%! a = sym([x; 0; 0]);
%! b = sym([0; 1; 0]);
%! c = cross(a, b);
%! assert (isequal (c, sym([0; 0; x])))
