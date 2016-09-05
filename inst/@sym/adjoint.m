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
%% @defmethod @@sym adjoint (@var{x})
%% Adjoint of symbolic square matrix.
%%
%% Example:
%% @example
%% @group
%% A = [sym(1); 2];
%% y =  adjoint(A)
%%   @result{} y = (sym) [1  2]  (1×2 matrix)
%% @end group
%% @end example
%% @end defmethod

%% Source: http://docs.sympy.org/dev/modules/matrices/matrices.html

function y = adjoint(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = python_cmd('return _ins[0].adjoint(),', x);
end

%!test
%! syms x
%! A = [x x^2; x^3 x^4];
%! B = [conj(x) conj(x)^3; conj(x)^2 conj(x)^4];
%! assert( isequal( adjoint(A), B ))
