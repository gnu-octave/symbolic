%% Copyright (C) 2017-2018 Colin B. Macdonald
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
%% @deftypemethod  @@sym {@var{Em} =} euler (@var{m})
%% @deftypemethodx @@sym {@var{p} =}  euler (@var{m}, @var{x})
%% Return symbolic Euler numbers or Euler polynomials.
%%
%% Examples:
%% @example
%% @group
%% euler (sym(0))
%%   @result{} (sym) 1
%% euler (sym(32))
%%   @result{} (sym) 177519391579539289436664789665
%% @end group
%% @end example
%%
%% Polynomial example:
%% @example
%% @group
%% syms x
%% @c doctest: +SKIP_UNLESS(python_cmd('return Version(spver) > Version("1.1.1")'))
%% euler (2, x)
%%   @result{} (sym)
%%        2
%%       x  - x
%% @end group
%%
%% @group
%% @c doctest: +SKIP_UNLESS(python_cmd('return Version(spver) > Version("1.1.1")'))
%% euler (10, x)
%%   @result{} (sym)
%%        10      9       7        5        3
%%       x   - 5⋅x  + 30⋅x  - 126⋅x  + 255⋅x  - 155⋅x
%% @end group
%% @end example
%%
%% (Euler polynomials require SymPy 1.2 or greater, released 2018-07).
%%
%% @seealso{@@double/euler, @@sym/bernoulli}
%% @end deftypemethod

function r = euler (varargin)

  if (nargin ~= 1 && nargin ~= 2)
    print_usage ();
  end

  for i = 1:nargin
    varargin{i} = sym (varargin{i});
  end

  r = elementwise_op ('euler', varargin{:});

end


%!error <usage> euler (sym(1), 2, 3)

%!assert (isequal (euler (sym(0)), sym(1)))

%!test
%! m = sym([0 1 2; 8 10 888889]);
%! A = euler (m);
%! B = sym([1 0 -1; 1385 -50521 0]);
%! assert (isequal (A, B))

%!test
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! syms x
%! assert (isequal (euler(6, x), x^6 - 3*x^5 + 5*x^3 - 3*x))
%! end

%!test
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! assert (isnan (euler (3, sym(nan))))
%! end

%!test
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! syms m x
%! em = euler (m, x);
%! A = subs(em, [m x], [2 sym(pi)]);
%! assert (isequal (A, sym(pi)^2 - sym(pi)))
%! end

%!test
%! % vectorized
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! syms x y
%! A = euler([1; 2], [x; y]);
%! B = [x - sym(1)/2; y^2 - y];
%! assert (isequal (A, B))
%! end

%!test
%! % round trip
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! syms m z
%! f = euler (m, z);
%! h = function_handle (f, 'vars', [m z]);
%! A = h (2, 2.2);
%! B = euler (2, 2.2);
%! assert (A, B)
%! end

%!test
%! % compare vpa to maple: Digits:=34; evalf(euler(13, exp(1)+Pi*I/13));
%! if (python_cmd('return Version(spver) > Version("1.1.1")'))
%! A = vpa('1623.14184180556920918624604530515') + ...
%!     vpa('4270.98066989140286451493108809574')*1i;
%! z = vpa (exp(1), 32) + vpa(pi, 32)/13*1i;
%! B = euler (13, z);
%! relerr = double(abs((B - A)/A));
%! assert (abs(relerr) < 2e-31);
%! end
