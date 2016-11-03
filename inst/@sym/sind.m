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
%% @defmethod @@sym sind (@var{x})
%% Symbolic sin function with input in degrees.
%%
%% Example:
%% @example
%% @group
%% 2*sind (sym (60))
%%   @result{} (sym) √3
%%
%% syms x
%% y = sind (x)
%%   @result{} y = (sym)
%%          ⎛π⋅x⎞
%%       sin⎜───⎟
%%          ⎝180⎠
%% @end group
%% @end example
%%
%% @seealso{@@sym/asind, @@sym/sin}
%% @end defmethod


function y = sind(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: sin(rad(a))', x);
end


%!error <Invalid> sind (sym(1), 2)
%!assert (isequaln (sind (sym(nan)), sym(nan)))

%!test
%! f1 = sind (sym(1));
%! f2 = sind (1);
%! assert (double (f1), f2, -eps)

%!test
%! D = [10 30; 110 -45];
%! A = sym(D);
%! f1 = sind (A);
%! f2 = sind (D);
%! assert (double (f1), f2, -eps)
