%% Copyright (C) 2015-2016, 2018-2019 Colin B. Macdonald
%% Copyright (C) 2016 Alex Vong
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
%% @defmethod @@sym dot (@var{a}, @var{b})
%% Symbolic dot (scalar) product.
%%
%% This function computes 'sum (conj (A) .* B)'.
%%
%% Examples:
%% @example
%% @group
%% a = [sym('a1'); sym('a2'); sym('a3')];
%% b = [sym('b1'); sym('b2'); sym('b3')];
%% dot(a, b)
%%   @result{} (sym)
%%          __      __      __
%%       b₁⋅a₁ + b₂⋅a₂ + b₃⋅a₃
%% dot(a, a)
%%   @result{} (sym)
%%          __      __      __
%%       a₁⋅a₁ + a₂⋅a₂ + a₃⋅a₃
%% @end group
%% @end example
%%
%% @example
%% @group
%% syms x
%% a = [x; 0; 0];
%% b = [0; 0; sym(1)];
%% dot(a, b)
%%   @result{} ans = (sym) 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/cross}
%% @end defmethod


function c = dot(a, b)

  if (nargin ~= 2)
    print_usage ();
  end

  % conjugate a to match the behavior of @double/dot
  cmd = { 'a, b = _ins'
          'if Version(spver) <= Version("1.3"):'
          '    return a.conjugate().dot(b)'
          'return a.dot(b, hermitian=True, conjugate_convention="left")'
        };

  c = pycall_sympy__ (cmd, sym(a), sym(b));

end


%!error <Invalid> dot (sym(1), 2, 3)

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
