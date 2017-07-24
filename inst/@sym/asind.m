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
%% @defmethod @@sym asind (@var{x})
%% Symbolic inverse sin function with output in degrees.
%%
%% Example:
%% @example
%% @group
%% asind (sqrt (sym (2))/2)
%%   @result{} (sym) 45
%%
%% syms x
%% y = asind (x)
%%   @result{} y = (sym)
%%       180⋅asin(x)
%%       ───────────
%%            π
%% @end group
%% @end example
%%
%% @seealso{@@sym/sind, @@sym/asin}
%% @end defmethod


function y = asind(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: deg(asin(a))', x);
end


%!error <Invalid> asind (sym(1), 2)
%!assert (isequaln (asind (sym(nan)), sym(nan)))

%!test
%! f1 = asind (sym(1)/2);
%! f2 = asind (1/2);
%! assert (double (f1), f2, -eps)

%!test
%! D = [1 2; 3 4]/4;
%! A = sym([1 2; 3 4])/4;
%! f1 = asind (A);
%! f2 = asind (D);
%! assert (double (f1), f2, -eps)
