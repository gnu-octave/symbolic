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
%% @defmethod @@sym tand (@var{x})
%% Symbolic tan function with input in degrees.
%%
%% Example:
%% @example
%% @group
%% tand (sym (60))
%%   @result{} (sym) √3
%%
%% syms x
%% y = tand (x)
%%   @result{} y = (sym)
%%          ⎛π⋅x⎞
%%       tan⎜───⎟
%%          ⎝180⎠
%% @end group
%% @end example
%%
%% @seealso{@@sym/atand, @@sym/tan}
%% @end defmethod


function y = tand(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: tan(rad(a))', x);
end


%!error <Invalid> tand (sym(1), 2)
%!assert (isequaln (tand (sym(nan)), sym(nan)))

%!test
%! f1 = tand (sym(1));
%! f2 = tand (1);
%! assert (double (f1), f2, -eps)

%!test
%! D = [10 30; 110 -45];
%! A = sym(D);
%! f1 = tand (A);
%! f2 = tand (D);
%! assert (double (f1), f2, -eps)
