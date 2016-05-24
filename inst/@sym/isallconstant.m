%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@sym isallconstant (@var{x})
%% Whether all elements of a symbolic array are constant.
%%
%% Example:
%% @example
%% @group
%% A = [1 2 sym(pi); sym(4) 5 6]
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡1  2  π⎤
%%       ⎢       ⎥
%%       ⎣4  5  6⎦
%%
%% isallconstant (A)
%%   @result{} ans = 1
%% @end group
%%
%% @group
%% A(1) = sym('x')
%%   @result{} A = (sym 2×3 matrix)
%%       ⎡x  2  π⎤
%%       ⎢       ⎥
%%       ⎣4  5  6⎦
%%
%% isallconstant (A)
%%   @result{} ans = 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/isconstant, @@sym/symvar, findsymbols}
%% @end defmethod


function z = isallconstant(x)

  z = isempty (findsymbols (x));

end


%!assert (isallconstant([sym(1) 2 3]))

%!test
%! syms x
%! assert (~isallconstant([sym(1) x 3]))

%!test
%! syms x
%! assert (~isallconstant([sym(1) x; sym(2) 3]))
