%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z} =} mat_mask_access (@var{A}, @var{I})
%% Private helper routine for symbolic array access via mask.
%%
%% Notes on shape, from observing Matlab/Octave behaviour on doubles:
%% @itemize
%% @item If A is a vector, Z always has the same orientation as A.
%% @item If A is a matrix and if I is a vector than Z has the same
%%       orientation as I.
%% @item In all other cases (?) result is a column vector.
%% @end itemize
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function Z = mat_mask_access(A, I)

  if (~islogical(I))
    error('subscript indices must be either positive integers or logicals')
  end
  if (numel(A) ~= numel(I))
    error('size A not compatible w/ size I in A(I)')
  end
  if (~(is_same_shape(A,I)))
    % this is not an error, but quite likely reflects a user error
    warning('OctSymPy:subsref:index_matrix_not_same_shape', ...
            'A and I in A(I) not same shape: no problem, but did you intend this?')
  end

  % issue #18 fix a(t/f)=6
  if (isscalar(A))
    if (I)
      Z = A;
    else
      Z = sym([]);
    end
    return
  end

  % careful, if you have persistence/caching, do these need .copy?
  cmd = { '(A, mask, n, m) = _ins'
          '# transpose b/c SymPy is row-based'
          'AT = A.T'
          'maskT = mask.T'
          'M = sp.Matrix.zeros(m, n)  # row-based'
          'j = 0'
          'for i in range(0,len(A)):'
          '    if maskT[i]:'
          '        M[j] = AT[i]'
          '        j = j + 1'
          'return M.T,' };

  % old Matlab (e.g., 2008) has no isrow/iscolumn, but we want A
  % and I to be sym eventually, so just do it here first.  But in
  % (common) case where I is nonsym (logical), its faster to call
  % nnz on the nonsym I.
  A = sym(A);
  Is = sym(I);
  % output shape, see logic in comments above
  if (isrow(A))
    n = 1;  m = nnz(I);
  elseif (iscolumn(A))
    n = nnz(I);  m = 1;
  elseif (isrow(Is))
    n = 1;  m = nnz(I);
  elseif (iscolumn(Is))
    n = nnz(I);  m = 1;
  else
    n = nnz(I);  m = 1;
  end

  Z = python_cmd (cmd, A, Is, n, m);
end


%% Note: tests in @sym/private/ not executed
% To run these in the test suite, you could move this mfile up to @sym.
% However, note these are generally tested elsewhere indirectly.

%!test
%! % 2D arrays
%! b = [1:4]; b = [b; 3*b; 5*b];
%! a = sym(b);
%! I = rand(size(b)) > 0.5;
%! assert(isequal( mat_mask_access(a,I), b(I) ))
%! I = I(:);
%! s = warning ('off', 'OctSymPy:subsref:index_matrix_not_same_shape');
%! assert(isequal( mat_mask_access(a,I), b(I) ))
%! I = I';
%! assert(isequal( mat_mask_access(a,I), b(I) ))
%! warning (s)
%! I = logical(zeros(size(b)));
%! assert(isequal( mat_mask_access(a,I), b(I) ))

%!warning <not same shape>
%! % some warnings when I is wrong shape
%! r = [1:6];
%! ar = sym(r);
%! c = r';
%! ac = sym(c);
%! Ir = rand(size(r)) > 0.5;
%! Ic = rand(size(c)) > 0.5;
%! temp = mat_mask_access(ar, Ic);
%! temp = mat_mask_access(ac, Ir);

%!test
%! % 1D arrays
%! r = [1:6];
%! ar = sym(r);
%! c = r';
%! ac = sym(c);
%! Ir = rand(size(r)) > 0.5;
%! Ic = rand(size(c)) > 0.5;
%! assert (isequal (mat_mask_access(ar,Ir), r(Ir)))
%! assert (isequal (mat_mask_access(ac,Ic), c(Ic)))
%! s = warning ('off', 'OctSymPy:subsref:index_matrix_not_same_shape');
%! assert (isequal (mat_mask_access(ar,Ic), r(Ic)))
%! assert (isequal (mat_mask_access(ac,Ir), c(Ir)))
%! warning (s)
