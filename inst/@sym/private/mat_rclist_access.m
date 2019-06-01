%% Copyright (C) 2014, 2016, 2019 Colin B. Macdonald
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
%% @defun mat_rclist_access (@var{A}, @var{r}, @var{c})
%% Private helper routine for sym array access via lists of row/col.
%%
%% @code{(r(i),c(i))} specify entries of the matrix @var{A}.
%% Returns a column vector of these extracted from @var{A}.
%%
%% @end defun


function z = mat_rclist_access(A, r, c)

  if ~( isvector(r) && isvector(c) && (length(r) == length(c)) )
    error('this routine is for a list of rows and cols');
  end

  cmd = { '(A, rr, cc) = _ins'
          'if A is None or not A.is_Matrix:'
          '    A = sp.Matrix([A])'
          'n = len(rr)'
          'M = sp.Matrix.zeros(n, 1)'
          'for i in range(0,n):'
          '    M[i,0] = A[rr[i],cc[i]]'
          'return M,' };

  rr = num2cell(int32(r-1));
  cc = num2cell(int32(c-1));
  z = pycall_sympy__ (cmd, A, rr, cc);
end
