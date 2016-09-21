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
%% @defmethod @@sym chol (@var{A})
%% Cholesky factorization of symbolic matrix.
%% @end defmethod

%% Reference: http://docs.sympy.org/dev/modules/matrices/matrices.html


function y = chol(x)
  if (nargin == 2)
    error('Operation not supported yet.');
  elseif (nargin > 2)
    print_usage ();
  end
  y = python_cmd('return _ins[0].cholesky(),', x);
end


%!test
%! A = chol(hilb(sym(2)));
%! B = [[1 0]; sym(1)/2 sqrt(sym(3))/6];
%! assert( isequal( A, B ))
