%% Copyright (C) 2015-2016, 2018 Colin B. Macdonald
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
%% @defmethod  @@sym linspace (@var{a}, @var{b})
%% @defmethodx @@sym linspace (@var{a}, @var{b}, @var{n})
%% Return a symbolic vector of equispaced points.
%%
%% Examples:
%% @example
%% @group
%% h = linspace(sym(1), sym(2), 3)
%%   @result{} h = (sym) [1  3/2  2]  (1×3 matrix)
%% h = linspace(sym(1), sym(10), 12)
%%   @result{} h = (sym 1×12 matrix)
%%       ⎡   20  29  38  47  56  65  74  83  92  101    ⎤
%%       ⎢1  ──  ──  ──  ──  ──  ──  ──  ──  ──  ───  10⎥
%%       ⎣   11  11  11  11  11  11  11  11  11   11    ⎦
%% @end group
%% @end example
%%
%% If @var{n} is omitted, a default value is used:
%% @example
%% @group
%% length(linspace(sym(pi)/2, sym(pi)))
%%   @result{} 100
%% @end group
%% @end example
%%
%% @seealso{@@sym/logspace, @@sym/colon}
%% @end defmethod


function r = linspace(a, b, N)

  if (nargin == 2)
    N = 100;
  elseif (nargin == 3)
    % nop
  else
    print_usage ();
  end

  % special case, see Octave "help linspace".
  if (logical(N < 2))
    r = b;
    return
  end

  a = sym(a);
  b = sym(b);

  d = (b - a) / (N-1);

  r = a + (sym(0):(N-1))*d;

end


%!test
%! a = linspace(sym(3), 5, 5);
%! b = [sym(6) 7 8 9 10]/2;
%! assert (isequal (a, b))

%!test
%! % non-integers
%! A = linspace(0, sym(pi), 10);
%! assert (length (A) == 10);
%! assert (isequal (A(6), 5*sym(pi)/9));

%!test
%! % default argument for N
%! A = linspace(1, 100);
%! assert (length (A) == 100);

%!test
%! % special case for just N = 1
%! A = linspace(sym(2), 3, 1);
%! assert (isequal (A, 3))
%! A = linspace(sym(2), 3, 0);
%! assert (isequal (A, 3))
%! A = linspace(sym(2), 3, sym(3)/2);
%! assert (isequal (A, 3))
