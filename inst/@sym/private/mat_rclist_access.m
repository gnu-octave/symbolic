%% Copyright (C) 2014, 2016, 2019, 2022 Colin B. Macdonald
%% Copyright (C) 2022 Alex Vong
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

  cmd = {'dbg_no_array = True'
         '(A, rr, cc) = _ins'
         'AA = A.tolist() if isinstance(A, (MatrixBase, NDimArray)) else [[A]]'
         'MM = [[AA[i][j]] for i, j in zip(rr, cc)]'
         'M = make_matrix_or_array(MM)'
         'return M,'};

  rr = num2cell(int32(r-1));
  cc = num2cell(int32(c-1));
  z = pycall_sympy__ (cmd, A, rr, cc);
end
