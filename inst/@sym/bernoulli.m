%% SPDX-License-Identifier: GPL-3.0-or-later
%% Copyright (C) 2014-2016, 2018-2019, 2022-2024 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{B} =} bernoulli (@var{n})
%% @deftypemethodx @@sym {@var{p} =} bernoulli (@var{n}, @var{x})
%% Return symbolic Bernoulli numbers or Bernoulli polynomials.
%%
%% With a sufficiently recent SymPy version, the first seven
%% Bernoulli numbers are:
%% @example
%% @group
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) >= Version("1.12")'))
%% bernoulli (sym(0:6))
%%   @result{} (sym) [1  1/2  1/6  0  -1/30  0  1/42]  (1×7 matrix)
%% @end group
%% @end example
%%
%% Note there are two different definitions in use which differ
%% in the sign of the value of B_1.  As of 2023 and a sufficiently
%% recent SymPy library, we use the definition with positive one half:
%% @example
%% @group
%% @c doctest: +XFAIL_UNLESS(pycall_sympy__ ('return Version(spver) >= Version("1.12")'))
%% bernoulli (sym(1))
%%   @result{} (sym) 1/2
%% @end group
%% @end example
%%
%% Other examples:
%% @example
%% @group
%% bernoulli (sym(6))
%%   @result{} (sym) 1/42
%% bernoulli (sym(7))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% Polynomial example:
%% @example
%% @group
%% syms x
%% bernoulli (2, x)
%%   @result{} (sym)
%%        2       1
%%       x  - x + ─
%%                6
%% @end group
%% @end example
%% @seealso{@@double/bernoulli, @@sym/euler}
%% @end deftypemethod

function r = bernoulli (varargin)

  if (nargin ~= 1 && nargin ~= 2)
    print_usage ();
  end

  for i = 1:nargin
    varargin{i} = sym (varargin{i});
  end

  r = elementwise_op ('bernoulli', varargin{:});

end


%!error bernoulli (sym(1), 2, 3)

%!assert (isequal (bernoulli (sym(8)), -sym(1)/30))
%!assert (isequal (bernoulli (sym(9)), sym(0)))
%!test syms x
%! assert (isequal (bernoulli(3,x), x^3 - 3*x^2/2 + x/2))

%!test
%! % two different definitions in literature
%! assert (isequal (abs (bernoulli (sym(1))), sym(1)/2))

%!test
%! % we use B_1 = 1/2
%! if (pycall_sympy__ ('return Version(spver) >= Version("1.12.dev")'))
%!   assert (isequal (bernoulli (sym(1)), sym(1)/2))
%! end

%!test
%! m = sym([0 2; 8 888889]);
%! A = bernoulli (m);
%! B = [1 sym(1)/6; -sym(1)/30 0];
%! assert (isequal (A, B))

%!test
%! syms x
%! A = bernoulli ([0; 1], x);
%! B = [sym(1); x - sym(1)/2];
%! assert (isequal (A, B))

%!test
%! % round trip
%! syms n x
%! f = bernoulli (n, x);
%! h = function_handle (f, 'vars', [n x]);
%! A = h (2, 2.2);
%! B = bernoulli (2, 2.2);
%! assert (A, B)
