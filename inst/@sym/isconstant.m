%% Copyright (C) 2014-2016, 2019, 2022 Colin B. Macdonald
%% Copyright (C) 2022 Chris Gorman
%%
%% This file is part of OctSymPy
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
%% @defmethod @@sym isconstant (@var{x})
%% Indicate which elements of symbolic array are constant.
%%
%% Example:
%% @example
%% @group
%% syms x y
%% A = [x 1 pi; 2 2*y catalan()]
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) >= Version("1.10")'))
%%   @result{} A = (sym 2×3 matrix)
%%      ⎡x   1   π⎤
%%      ⎢         ⎥
%%      ⎣2  2⋅y  G⎦
%%
%% isconstant (A)
%%   @result{} ans =
%%       0  1  1
%%       1  0  1
%% @end group
%% @end example
%%
%% @seealso{@@sym/isallconstant, @@sym/symvar, findsymbols}
%% @end defmethod


function z = isconstant(x)

  cmd = { '(x,) = _ins'
          'if isinstance(x, (MatrixBase, NDimArray)):'
          '    return x.applyfunc(lambda a: a.is_constant()),'
          'return x.is_constant(),' };
  z = pycall_sympy__ (cmd, sym(x));
  % Issue #27: Matrix of bools not converted to logical
  z = logical(z);

end


%!test
%! syms x
%! A = [x 2 3];
%! B = [false true true];
%! assert (isequal (isconstant (A), B))

%!test
%! syms x
%! A = [x 2; 3 x];
%! B = [false true; true false];
%! assert (isequal (isconstant (A), B))

%!error
%! % semantically not an error, but is using SymPy's Array
%! t = sym(true);
%! A = [t t];
%! isconstant (A);

%!error
%! syms x
%! A = [x == 10; x <= 10];
%! isconstant (A);
