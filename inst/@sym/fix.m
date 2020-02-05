%% Copyright (C) 2016 Lagu
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
%% @defmethod @@sym fix (@var{x})
%% Symbolic fix function.
%%
%% Example:
%% @example
%% @group
%% y = fix(sym(3)/2)
%%   @result{} y = (sym) 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/ceil, @@sym/floor, @@sym/frac, @@sym/round}
%% @end defmethod


function y = fix(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('Integer', x);
end


%!test
%! d = 3/2;
%! x = sym('3/2');
%! f1 = fix(x);
%! f2 = fix(d);
%! assert (isequal (f1, f2))

%!test
%! D = [1.1 4.6; -3.4 -8.9];
%! A = [sym(11)/10 sym(46)/10; sym(-34)/10 sym(-89)/10];
%! f1 = fix(A);
%! f2 = fix(D);
%! assert( isequal (f1, f2))

%!test
%! d = sym(-11)/10;
%! c = -1;
%! assert (isequal (fix (d), c))

%!test
%! d = sym(-19)/10;
%! c = -1;
%! assert (isequal (fix (d), c))
