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
%% @defmethod @@sym log2 (@var{x})
%% Symbolic log base 2 function.
%%
%% Examples:
%% @example
%% @group
%% log2(sym(256))
%%   @result{} ans = (sym) 8
%%
%% syms x
%% log2(x)
%%   @result{} ans = (sym)
%%       log(x)
%%       ──────
%%       log(2)
%% @end group
%% @end example
%%
%% @seealso{@@sym/log, @@sym/log10}
%% @end defmethod


function z = log2(x)

  z = elementwise_op ('lambda x: sp.log(x, 2)', x);

end


%!assert (isequal (log2 (sym (1024)), sym (10)))

%!assert (isequal (log2 (sym ([2 16; 32 1])), sym ([1 4; 5 0])))

%!test
%! % round-trip
%! syms x
%! f = log2 (x);
%! h = function_handle (f);
%! A = h (1.1);
%! B = log2 (1.1);
%! assert (A, B, -5*eps)
