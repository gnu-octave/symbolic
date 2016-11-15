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
%% @defmethod @@sym acosd (@var{x})
%% Symbolic inverse cos function with output in degrees.
%%
%% Example:
%% @example
%% @group
%% acosd (sqrt (sym (2))/2)
%%   @result{} (sym) 45
%%
%% syms x
%% y = acosd (x)
%%   @result{} y = (sym)
%%       180⋅acos(x)
%%       ───────────
%%            π
%% @end group
%% @end example
%%
%% @seealso{@@sym/cosd, @@sym/acos}
%% @end defmethod


function y = acosd(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: deg(acos(a))', x);
end


%!error <Invalid> acosd (sym(1), 2)
%!assert (isequaln (acosd (sym(nan)), sym(nan)))

%!test
%! f1 = acosd (sym(1)/2);
%! f2 = acosd (1/2);
%! assert (double (f1), f2, -eps)

%!test
%! D = [1 2; 3 4]/4;
%! A = sym([1 2; 3 4])/4;
%! f1 = acosd (A);
%! f2 = acosd (D);
%! assert (double (f1), f2, -eps)
