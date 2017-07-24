%% Copyright (C) 2016 Colin B. Macdonald
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
%% @defmethod @@sym sympy (@var{x})
%% The underlying SymPy representation as a string.
%%
%% Each symbolic @code{sym} expression has an underlying Python
%% object, which is stored as a character array consisting of the
%% the object's @code{srepr} (``String Representation'').
%% This method returns that string and can be helpful for debugging
%% or for copy-pasting a @code{sym} object into a Python environment
%% such as Jupyter.
%%
%% Example:
%% @example
%% @group
%% syms x positive
%% srepr = sympy (x)
%%   @result{} srepr = Symbol('x', positive=True)
%% @end group
%% @end example
%%
%% Unlike @code{@@sym/char}, the result can be passed directly back
%% to @code{sym} with perfect fidelity:
%% @example
%% @group
%% x2 = sym (srepr)
%%   @result{} x2 = (sym) x
%% x2 == x
%%   @result{} (sym) True
%% @end group
%% @end example
%%
%% @seealso{@@sym/char, @@sym/disp, @@sym/pretty, sym}
%% @end defmethod


function s = sympy(x)

  s = x.pickle;

end


%!assert (strcmp (sympy (sym(pi)), 'pi'))
%!assert (strcmp (sympy (sym(1)), 'Integer(1)'))
%!assert (strcmp (sympy (sym(2)/3), 'Rational(2, 3)'))
%!assert (strcmp (sympy (sym('x')), 'Symbol(''x'')'))

%!test
%! x = sym('x');
%! assert (isequal (sym(sympy(x)), x))
