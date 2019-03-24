%% Copyright (C) 2015, 2016, 2018 Colin B. Macdonald
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
%% @defmethod  @@sym logspace (@var{a}, @var{b})
%% @defmethodx @@sym logspace (@var{a}, @var{b}, @var{n})
%% Return a symbolic vector of logarithmically-spaced points.
%%
%% The result will be @var{n} points between @code{10^@var{a}}
%% and @code{10^@var{b}}, which are equispaced on a logscale.
%%
%% Examples:
%% @example
%% @group
%% logspace(sym(-2), 1, 4)
%%   @result{} (sym) [1/100  1/10  1  10]  (1×4 matrix)
%% logspace(sym(0), 3, 4)
%%   @result{} (sym) [1  10  100  1000]  (1×4 matrix)
%% @end group
%% @end example
%%
%% If omitted, @var{n} will default to 50.  A special case occurs
%% if @var{b} is @code{pi}; this gives logarithmically-spaced points
%% between @code{10^@var{a}} and @code{pi} instead:
%% @example
%% @group
%% logspace(0, sym(pi), 4)
%%   @result{} (sym 1×4 matrix)
%%       ⎡   3 ___   2/3   ⎤
%%       ⎣1  ╲╱ π   π     π⎦
%% @end group
%% @end example
%%
%% @code{logspace} can be combined with @code{vpa}:
%% @example
%% @group
%% logspace(vpa(-1), vpa(2), 5)'
%%   @result{} ans = (sym 5×1 matrix)
%%       ⎡               0.1                ⎤
%%       ⎢                                  ⎥
%%       ⎢0.56234132519034908039495103977648⎥
%%       ⎢                                  ⎥
%%       ⎢3.1622776601683793319988935444327 ⎥
%%       ⎢                                  ⎥
%%       ⎢17.782794100389228012254211951927 ⎥
%%       ⎢                                  ⎥
%%       ⎣              100.0               ⎦
%% @end group
%% @end example
%%
%% @seealso{@@sym/linspace}
%% @end defmethod


function r = logspace(a, b, N)

  if (nargin == 2)
    N = 50;
  elseif (nargin == 3)
    % nop
  else
    print_usage ();
  end

  a = sym(a);
  b = sym(b);

  spi = sym('pi');
  if (logical(b == spi))
    b = log10(spi);
  end

  e = linspace(a, b, N);

  r = 10.^e;
end


%!test
%! % default argument for N
%! A = logspace(0, 2);
%! assert (length (A) == 50);

%!test
%! % special case: pi as end pt
%! A = logspace(-sym(3), sym(pi), 3);
%! assert (isequal (A(end), sym(pi)))

%!test
%! A = logspace(-sym(4), 0, 3);
%! B = [sym(1)/10000  sym(1)/100  sym(1)];
%! assert (isequal (A, B))

%!test
%! % vpa support, might need recent sympy for sympy issue #10063
%! n = 32;
%! A = logspace(-vpa(1,n), 0, 3);
%! B = [10^(-vpa(1,n)) 10^(-vpa(sym(1)/2,n)) vpa(1,n)];
%! assert (isequal (A, B))
%! assert (max(abs(double(A) - logspace(-1, 0, 3))) < 1e-15)
