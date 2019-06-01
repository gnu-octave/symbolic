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
%% @documentencoding UTF-8
%% @defmethod @@sym nnz (@var{A})
%% Number of non-zero elements in the symbolic array.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 0 0; 0 1 0]);
%% nnz(A)
%%   @result{} ans =  2
%% @end group
%% @end example
%%
%% @seealso{@@sym/numel}
%% @end defmethod


function n = nnz(A)

  % some future-proofing here for supporting symbolic sparse matrices
  % but what is SparseMatrix has bools in it?

  cmd = {
    'def scalar2tf(a):'
    '    if a in (S.true, S.false):'
    '        return bool(a)'
    %'    if a is S.NaN:'
    %'        return True'
    '    return a != 0'
    'A = _ins[0]'
    'if not A.is_Matrix:'
    '    A = sp.Matrix([A])'
    'try:'
    '    n = A.nnz()'
    'except AttributeError:'
    '    n = sum([scalar2tf(a) for a in A])'
    'return n,'
  };

  n = pycall_sympy__ (cmd, A);

end


%!assert (nnz (sym ([1])) == 1)
%!assert (nnz (sym ([0])) == 0)
%!assert (nnz (sym ([])) == 0)
%!assert (nnz (sym ([1 0; 0 3])) == 2)

%!test
%! syms x
%! assert (nnz ([x 0]) == 1)

%!assert (nnz (sym (true)) == 1)
%!assert (nnz (sym (false)) == 0)


%!assert (nnz (sym (inf)) == 1)
%!assert (nnz (sym (nan)) == 1)
