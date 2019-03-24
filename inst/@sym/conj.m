%% Copyright (C) 2014, 2016, 2018 Colin B. Macdonald
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
%% @defmethod @@sym conj (@var{z})
%% Symbolic conjugate function.
%%
%% Examples:
%% @example
%% @group
%% syms z
%% conj(z)
%%   @result{} ans = (sym)
%%       _
%%       z
%%
%% @end group
%% @group
%% syms x real
%% conj(x)
%%   @result{} ans = (sym) x
%%
%% conj(sym(pi) + 6i)
%%   @result{} ans = (sym) π - 6⋅ⅈ
%% @end group
%% @end example
%%
%% Unlike @ref{@@sym/ctranspose}, this command does not transpose
%% a matrix:
%% @example
%% @group
%% A = [1 z x; sym(4) 5 6+7i]
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡1  z     x   ⎤
%%       ⎢             ⎥
%%       ⎣4  5  6 + 7⋅ⅈ⎦
%% conj(A)
%%   @result{} ans = (sym 2×3 matrix)
%%       ⎡   _         ⎤
%%       ⎢1  z     x   ⎥
%%       ⎢             ⎥
%%       ⎣4  5  6 - 7⋅ⅈ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/ctranspose, @@sym/real, @@sym/imag}
%% @end defmethod

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = conj(x)

  if (nargin ~= 1)
    print_usage ();
  end

  % can just use .conjugate on matrix but avoids S.true err
  sf = { 'def _op(x):'
         '    if x in (S.true, S.false):'
         '        return x'
         '    return x.conjugate()' };

  z = elementwise_op (sf, x);

end


%!test
%! a = sym(6);
%! b = sym(5i);
%! assert (isequal (conj(a), a))
%! assert (isequal (conj(b), -b))
%! assert (isequal (conj(a+b), a-b))

%!test
%! syms x
%! assert (isequal (conj(conj(x)), x))

%!test
%! syms x real
%! assert (isequal (conj(x), x))

%!test
%! % array
%! syms x
%! A = [x 6+1i; sym(1) x+2i];
%! B = [conj(x) 6-1i; sym(1) conj(x)-2i];
%! assert (isequal (conj(A), B))

%!test
%! % true/false
%! t = sym(true);
%! f = sym(false);
%! assert (isequal ( conj(t), t))
%! assert (isequal ( conj(f), f))

%!test
%! % round trip
%! syms x
%! d = 3 - 5i;
%! f = conj (x);
%! A = conj (d);
%! h = function_handle (f);
%! B = h (d);
%! assert (A, B)
