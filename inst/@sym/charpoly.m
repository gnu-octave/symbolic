%% Copyright (C) 2016 Lagu
%% Copyright (C) 2017 Colin B. Macdonald
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
%% @defmethod @@sym charpoly (@var{A})
%% @defmethodx @@sym charpoly (@var{A}, @var{x})
%% Characteristic polynomial of symbolic matrix.
%%
%% Numerical example:
%% @example
%% @group
%% A = sym([1 2; 3 4]);
%% mu = sym('mu');
%% charpoly (A, mu)
%%   @result{} (sym)
%%        2
%%       μ  - 5⋅μ - 2
%% @end group
%% @end example
%%
%% We can then manipulate the characteristic polynomial, for example:
%% @example
%% @group
%% b(mu) = charpoly (A, mu)
%%   @result{} b(mu) = (symfun)
%%        2
%%       μ  - 5⋅μ - 2
%% b(1)
%%   @result{} (sym) -6
%% @end group
%% @end example
%% We can also confirm that the characteristic polynomial is zero
%% at an eigenvalue:
%% @example
%% @group
%% ev = eig(A);
%% simplify(b(ev(1)))
%%   @result{} (sym) 0
%% @end group
%% @end example
%%
%% The matrix can contain symbols:
%% @example
%% @group
%% syms x
%% charpoly ([x x;1 x], sym('lambda'))
%%   @result{} (sym)
%%        2            2
%%       λ  - 2⋅λ⋅x + x  - x
%% @end group
%% @end example
%%
%% If @var{x} is omitted, the polynomial coefficients are returned:
%% @example
%% @group
%% charpoly (sym([4 1;3 9]))
%%   @result{} ans = (sym) [1  -13  33]  (1×3 matrix)
%% @end group
%% @end example
%%
%% @seealso{@@sym/eig, @@sym/jordan}
%% @end defmethod

%% Reference: http://docs.sympy.org/dev/modules/matrices/matrices.html


function y = charpoly(varargin)
  if (nargin >= 3)
    print_usage ();
  end

  cmd = {'if len(_ins) == 1:'
         '    a = Dummy()'
         '    return Poly.from_expr(_ins[0].charpoly(a).as_expr(), a).all_coeffs(),'
         'else:'
         '    return _ins[0].charpoly(_ins[1]).as_expr(),'};

  for i = 1:nargin
    varargin{i} = sym(varargin{i});
  end
  y = python_cmd(cmd, varargin{:});

  if (nargin == 1)
    y = cell2sym(y);
  end

end


%!test
%! syms x
%! A = sym([x x; x x]);
%! assert( isequal( charpoly(A, x), -x^2))

%!test
%! syms x
%! A = sym([1 2; 3 4]);
%! assert( isequal( charpoly(A, x), x^2 - 5*x -2))

%!test
%! syms x
%! A = sym([x x; x x]);
%! B = sym([1 -2*x 0]);
%! assert( isequal( charpoly(A), B))

%!xtest
%! syms x
%! A = sym([1 2; 3 4]);
%! B = sym([1 -5 -2]);
%! assert( isequal( charpoly(A), B))
