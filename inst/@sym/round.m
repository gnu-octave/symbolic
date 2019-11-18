%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016 Mike Miller
%% Copyright (C) 2016, 2019 Colin B. Macdonald
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
%% @defmethod @@sym round (@var{x})
%% Symbolic round function.
%%
%% Example:
%% @example
%% @group
%% y = round (sym(-27)/10)
%%   @result{} y = (sym) -3
%% @end group
%% @end example
%%
%% Note as of SymPy 1.5, this function rounds toward even:
%% @example
%% @c doctest: +SKIP_UNLESS(pycall_sympy__ ('return Version(spver) > Version("1.4")'))
%% @group
%% round ([sym(5)/2 sym(7)/2])
%%   @result{} (sym) [2  4]  (1×2 matrix)
%% @end group
%% @end example
%% This differs from the builtin numeric function @pxref{round};
%% it corresponds to the builtin Octave function @pxref{roundb}.
%% @example
%% @group
%% round ([5/2 7/2])
%%   @result{} 3  4
%% roundb ([5/2 7/2])
%%   @result{} 2  4
%% @end group
%% @end example
%%
%% @seealso{roundb, @@sym/ceil, @@sym/floor, @@sym/fix, @@sym/frac}
%% @end defmethod


function y = round(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda a: Integer(a.round()) if isinstance(a, Number) else a.round()', x);
end


%!test
%! d = 3/2;
%! x = sym('3/2');
%! f1 = round(x);
%! f2 = round(d);
%! assert (isequal (f1, f2))

%!xtest
%! % ideally rounding direction would match Octave
%! d = 5/2;
%! x = sym('5/2');
%! f1 = round(x);
%! f2 = round(d);
%! assert (isequal (f1, f2))

%!test
%! D = [1.1 4.6; -3.4 -8.9];
%! A = [sym(11)/10 sym(46)/10; sym(-34)/10 sym(-89)/10];
%! f1 = round(A);
%! f2 = round(D);
%! assert( isequal (f1, f2))

%!test
%! d = sym(-11)/10;
%! c = -1;
%! assert (isequal (round (d), c))

%!test
%! d = sym(-19)/10;
%! c = -2;
%! assert (isequal (round (d), c))

%!test
%! d = 7j/2;
%! x = sym(7j)/2;
%! f1 = round (x);
%! f2 = round (d);
%! assert (isequal (f1, f2))

%!test
%! d = 5/3 - 4j/7;
%! x = sym(5)/3 - sym(4j)/7;
%! f1 = round (x);
%! f2 = round (d);
%! assert (isequal (f1, f2))
