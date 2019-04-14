%% Copyright (C) 2016 Lagu
%% Copyright (C) 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@sym angle (@var{x})
%% @defmethodx @@sym arg (@var{x})
%% Symbolic polar angle.
%%
%% Example:
%% @example
%% @group
%% x = sym(2+3*i);
%% y = angle(x)
%%   @result{} y = (sym) atan(3/2)
%% @end group
%% @end example
%% @seealso{angle, @@sym/abs}
%% @end defmethod


function y = angle (x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('arg', x);
end


%!test
%! Z = [sqrt(sym(3)) + 3*sym(i), 3 + sqrt(sym(3))*sym(i); 1 + sym(i), sym(i)];
%! Q = [sym(pi)/3 sym(pi)/6; sym(pi)/4 sym(pi)/2];
%! assert( isequal( angle(Z), Q));

%!test
%! % roundtrip
%! syms x
%! A = angle (2+2i);
%! f = angle (x);
%! h = function_handle (f);
%! B = h (2+2i);
%! assert (A, B, -eps)
