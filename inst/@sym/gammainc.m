%% Copyright (C) 2016, 2018-2019 Colin B. Macdonald
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
%% @defmethod  @@sym gammainc (@var{x}, @var{a})
%% @defmethodx @@sym gammainc (@var{x}, @var{a}, 'lower')
%% @defmethodx @@sym gammainc (@var{x}, @var{a}, 'upper')
%% Symbolic regularized incomplete gamma function.
%%
%% Example:
%% @example
%% @group
%% syms x a
%% gammainc(x, a)
%%   @result{} (sym)
%%       γ(a, x)
%%       ───────
%%         Γ(a)
%% @end group
%%
%% @group
%% gammainc(x, a, 'upper')
%%   @result{} (sym)
%%       Γ(a, x)
%%       ───────
%%         Γ(a)
%% @end group
%% @end example
%%
%% @strong{Note} the order of inputs is swapped in the displayed
%% symbolic expression, @ref{@@sym/igamma}.  This is purely cosmetic
%% and does not effect operations on the results:
%% @example
%% @group
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% gammainc(3, 1)
%%   @result{} ans = 0.9502
%% gammainc(x, a)
%%   @result{} (sym)
%%       γ(a, x)
%%       ───────
%%         Γ(a)
%% @c doctest: +SKIP_IF(compare_versions (OCTAVE_VERSION(), '6.0.0', '<'))
%% double(subs(ans, [x a], [3 1]))
%%   @result{} ans = 0.9502
%% @end group
%% @end example
%%
%% @seealso{gammainc, @@sym/igamma, @@sym/gamma}
%% @end defmethod

function y = gammainc(z, a, which)
  if (nargin == 2)
    which = 'lower';
  elseif (nargin == 3)
    % no-op
  else
    print_usage ();
  end

  if (strcmp(which, 'lower'))
    y = elementwise_op ('lowergamma', sym(a), sym(z));
  elseif (strcmp(which, 'upper'))
    y = elementwise_op ('uppergamma', sym(a), sym(z));
  else
    print_usage ();
  end
  y = y ./ gamma (a);
end


%!assert (isequal (gammainc (sym(0), 1), sym(0)))
%!assert (isequal (gammainc (sym(0), 2), sym(0)))
%!assert (isequal (gammainc (sym('oo'), 1), sym(1)))

%!assert (isequal (gammainc (sym(0), 1, 'upper'), sym(1)))
%!assert (isequal (gammainc (sym(0), 2, 'upper'), sym(1)))
%!assert (isequal (gammainc (sym('oo'), 1, 'upper'), sym(0)))

%!test
%! % default is lower
%! syms x a
%! assert (isequal (gammainc (x, a), gammainc(x, a, 'lower')))

%!test
%! % compare to double
%! x = 5; a = 1;
%! A = gammainc (x, a);
%! B = double (gammainc (sym(x), a));
%! assert(A, B, -eps)

%!test
%! % compare to double where gamma(a) != 1
%! x = 5; a = 3;
%! A = gammainc (x, a);
%! B = double (gammainc (sym(x), a));
%! assert(A, B, -eps)

%!test
%! % compare to double
%! x = 100; a = 1;
%! A = gammainc (x, a);
%! B = double (gammainc (sym(x), a));
%! assert(A, B, -eps)

%!test
%! % compare to double
%! xs = sym(1)/1000; x = 1/1000; a = 1;
%! A = gammainc (x, a);
%! B = double (gammainc (xs, a));
%! assert(A, B, -eps)

%!test
%! % compare to double
%! x = 5; a = 1;
%! A = gammainc (x, a, 'upper');
%! B = double (gammainc (sym(x), a, 'upper'));
%! assert(A, B, -10*eps)

%!test
%! % compare to double
%! % https://savannah.gnu.org/bugs/index.php?47800
%! if (~ exist('OCTAVE_VERSION', 'builtin') || ...
%!     compare_versions (OCTAVE_VERSION (), '4.3.0', '>='))
%! x = 10; a = 1;
%! A = gammainc (x, a, 'upper');
%! B = double (gammainc (sym(x), a, 'upper'));
%! assert(A, B, -10*eps)
%! end

%!test
%! % compare to double
%! if (~ exist('OCTAVE_VERSION', 'builtin') || ...
%!     compare_versions (OCTAVE_VERSION (), '4.3.0', '>='))
%! x = 40; a = 1;
%! A = gammainc (x, a, 'upper');
%! B = double (gammainc (sym(x), a, 'upper'));
%! assert(A, B, -10*eps)
%! end

%!test
%! % compare to double
%! xs = sym(1)/1000; x = 1/1000; a = 1;
%! A = gammainc (x, a, 'upper');
%! B = double (gammainc (xs, a, 'upper'));
%! assert(A, B, -eps)

%!test
%! % vectorized
%! P = gammainc([sym(pi) 2], [1 3]);
%! expected = [gammainc(pi, sym(1))  gammainc(2, sym(3))];
%! assert (isequal (P, expected))

%!test
%! % vectorized
%! P = gammainc(sym(pi), [1 3]);
%! expected = [gammainc(sym(pi), 1)  gammainc(sym(pi), 3)];
%! assert (isequal (P, expected))

%!test
%! % vectorized
%! P = gammainc([sym(pi) 2], 1);
%! expected = [gammainc(pi, sym(1))  gammainc(2, sym(1))];
%! assert (isequal (P, expected))

%!test
%! % round trip
%! syms x a
%! f = gammainc (x, a, 'upper');
%! h = function_handle (f, 'vars', [x a]);
%! A = h (1.1, 2);
%! B = gammainc (1.1, 2, 'upper');
%! assert (A, B)

%!test
%! % round trip
%! syms x a
%! f = gammainc (x, a, 'lower');
%! h = function_handle (f, 'vars', [x a]);
%! A = h (1.1, 2);
%! B = gammainc (1.1, 2, 'lower');
%! assert (A, B)

%!test
%! % round trip
%! syms x a
%! f = gammainc (x, a, 'upper');
%! h = function_handle (f, 'vars', [x a]);
%! A = h (1.1, 2.2);
%! B = gammainc (1.1, 2.2, 'upper');
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%! assert (A, B)
%! end

%!test
%! % round trip
%! syms x a
%! f = gammainc (x, a, 'lower');
%! h = function_handle (f, 'vars', [x a]);
%! A = h (1.1, 2.2);
%! B = gammainc (1.1, 2.2, 'lower');
%! if (pycall_sympy__ ('return Version(spver) > Version("1.3")'))
%! assert (A, B)
%! end
