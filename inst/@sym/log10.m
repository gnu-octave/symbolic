%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @defmethod @@sym log10 (@var{x})
%% Symbolic log base 10 function.
%%
%% Examples:
%% @example
%% @group
%% log10(sym(1000))
%%   @result{} ans = (sym) 3
%%
%% syms x
%% log10(x)
%%   @result{} ans = (sym)
%%        log(x)
%%       ───────
%%       log(10)
%% @end group
%% @end example
%% @seealso{@@sym/log, @@sym/log2}
%% @end defmethod


function z = log10(x)

  z = elementwise_op ('lambda x: sp.log(x, 10)', x);

end


%!assert (isequal (log10 (sym (1000)), sym (3)))

%!assert (isequal (log10 (sym ([10 100])), sym ([1 2])))

%!test
%! % round-trip
%! syms x
%! f = log10 (x);
%! h = function_handle (f);
%! A = h (1.1);
%! B = log10 (1.1);
%! assert (A, B, -eps)
