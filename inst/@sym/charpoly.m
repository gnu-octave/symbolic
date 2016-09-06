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
%% @defmethod @@sym charpoly (@var{A})
%% @defmethodx @@sym charpoly (@var{A}, @var{x})
%% Characteristic polynomial of matrix.
%%
%% Example:
%% @example
%% @group
%% syms x
%% lambda = sym('lambda');
%% y(lambda) = charpoly ([x x;1 x], lambda)
%%   @result{} y(lamda) = (symfun)
%%   2            2    
%%  λ  - 2⋅λ⋅x + x  - x
%% @end group
%% @end example
%%
%% Numerical example:
%% @example
%% @group
%% A = sym([1 2; 3 4]);
%% mu = sym('mu');
%% y(mu) = charpoly (A, mu)
%%   @result{} y(mu) = (symfun)
%%   2          
%%  μ  - 5⋅μ - 2
%% @end group
%% @end example
%% @end defmethod


%% Source: http://docs.sympy.org/dev/modules/matrices/matrices.html

function y = charpoly(a, b)
  if (nargin >= 3)
    print_usage ();
  end
  if (nargin == 1)
    error('Charpoly as vector its not supported now');
  else
    y = python_cmd('return _ins[0].charpoly(_ins[1]).as_expr(),', sym(a), sym(b));
  end
end

%!test
%! syms x
%! A = sym([x x; x x]);
%! assert( isequal( charpoly(A, x), -x^2))

%!xtest
%! syms x
%! A = sym([1 2; 3 4]);
%! assert( isequal( charpoly(A, x), x^2 - 5*x -2))
