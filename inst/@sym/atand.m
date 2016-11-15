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
%% @defmethod @@sym atand (@var{x})
%% Symbolic inverse tan function with output in degrees.
%%
%% Example:
%% @example
%% @group
%% atand (sqrt (sym (3)))
%%   @result{} (sym) 60
%%
%% syms x
%% y = atand (x)
%%   @result{} y = (sym)
%%       180⋅atan(x)
%%       ───────────
%%            π
%% @end group
%% @end example
%%
%% @seealso{@@sym/tand, @@sym/atan}
%% @end defmethod


function y = atand(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: deg(atan(a))', x);
end


%!error <Invalid> atand (sym(1), 2)
%!assert (isequaln (atand (sym(nan)), sym(nan)))

%!test
%! f1 = atand (sym(1)/2);
%! f2 = atand (1/2);
%! assert (double (f1), f2, -eps)

%!test
%! D = [1 2; 3 4]/4;
%! A = sym([1 2; 3 4])/4;
%! f1 = atand (A);
%! f2 = atand (D);
%! assert (double (f1), f2, -eps)
