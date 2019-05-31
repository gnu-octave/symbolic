%% Copyright (C) 2014-2016, 2018-2019 Colin B. Macdonald
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
%% Examples:
%% @example
%% @group
%% bernoulli(sym(6))
%%   @result{} (sym) 1/42
%% bernoulli(sym(7))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% Polynomial example:
%% @example
%% @group
%% syms x
%% bernoulli(2, x)
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


%!error <usage> bernoulli (sym(1), 2, 3)

%!assert (isequal (bernoulli (sym(8)), -sym(1)/30))
%!assert (isequal (bernoulli (sym(9)), sym(0)))
%!test syms x
%! assert (isequal (bernoulli(3,x), x^3 - 3*x^2/2 + x/2))

%!test
%! m = sym([0 1; 8 888889]);
%! A = bernoulli (m);
%! B = [1 -sym(1)/2; -sym(1)/30 0];
%! assert (isequal (A, B))

%!test
%! syms x
%! A = bernoulli ([0; 1], x);
%! B = [sym(1); x - sym(1)/2];
%! assert (isequal (A, B))

%!test
%! % round trip
%! if (pycall_sympy__ ('return Version(spver) > Version("1.2")'))
%! syms n x
%! f = bernoulli (n, x);
%! h = function_handle (f, 'vars', [n x]);
%! A = h (2, 2.2);
%! B = bernoulli (2, 2.2);
%! assert (A, B)
%! end
