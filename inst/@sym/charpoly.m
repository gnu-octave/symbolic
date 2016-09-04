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
%% @defmethod @@sym charpoly (@var{x})
%% @defmethod @@sym charpoly (@var{x}, @var{y})
%% Characteristic polynomial of matrix.
%%
%% Example:
%% @example
%% @group
%% syms x
%% a = x*x;
%% y = charpoly ([x x;1 x], x)
%%   @result{} y = (sym)
%%   -x
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
%! A = sym([x, x;x, x]);
%! assert( isequal( charpoly(A, x), -x^2))

%!xtest
%! syms x
%! A = sym([1, 2;3, 4]);
%! assert( isequal( charpoly(A, x), x^2 - 5*x -2))
