%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@sym char (@var{x})
%% Return string representation of a symbolic expression.
%%
%% Example:
%% @example
%% @group
%% f = [sym(pi)/2 ceil(sym('x')/3); sym('alpha') sym(3)/2]
%%   @result{} f = (sym 2×2 matrix)
%%
%%       ⎡π  ⎡x⎤⎤
%%       ⎢─  ⎢─⎥⎥
%%       ⎢2  ⎢3⎥⎥
%%       ⎢      ⎥
%%       ⎣α  3/2⎦
%%
%% char(f)
%%   @result{} Matrix([[pi/2, ceiling(x/3)], [alpha, 3/2]])
%% @end group
%% @end example
%%
%% This command generally gives a human-readable string but it may not be
%% sufficient for perfect reconstruction of the symbolic expression.
%% For example @code{char(x)} does not display assumptions:
%% @example
%% @group
%% syms x positive
%% char (x)
%%   @result{} x
%% @end group
%% @end example
%% And because of this, passing the output of @code{char} to @code{sym}
%% loses information:
%% @example
%% @group
%% x2 = sym (char (x));
%%
%% assumptions (x2)
%%   @result{} ans =
%%       @{@}(0x0)
%% @end group
%% @end example
%%
%%
%% If you need a more precise string representation of a symbolic object,
%% the underlying SymPy string representation (“srepr”) can be found
%% using @code{sympy}:
%% @example
%% @group
%% sympy (x)
%%   @result{} ans = Symbol('x', positive=True)
%% @end group
%% @end example
%%
%% @seealso{@@sym/disp, @@sym/pretty, @@sym/sympy, sym}
%% @end defmethod


function s = char(x)

  s = x.flat;

end


%!test
%! % issue #91: expose as string
%! a = sym(pi);
%! assert (strcmp (char (a), 'pi'))

%!shared x
%! x = sym('x');

%!assert (strcmp (char (x), 'x'))
%!assert (strcmp (char (2*x), '2*x'))
%!assert (strcmp (char ([2*x x]), 'Matrix([[2*x, x]])'))
%!assert (strcmp (char ([2*x 2; 1 x]), 'Matrix([[2*x, 2], [1, x]])'))
