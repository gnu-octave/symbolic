function Z = mat_mask_access(A, I)
%MAT_MASK_ACCESS  Private helper routine
%   Z = mat_mask_access(A, I)
%
%   Notes on shape, from observing Matlab/Octave behaviour on doubles:
%
%   1) If A is a vector, Z always has the same orientation as A.
%
%   2) If A is a matrix and if I is a vector than Z has the same
%   orientation as I.
%
%   3) In all other cases (?) result is a column vector

  if (~islogical(I))
    error('subscript indices must be either positive integers or logicals')
  end
  if (numel(A) ~= numel(I))
    error('size A not compatible w/ size I in A(I)')
  end
  if (~(is_same_shape(A,I)))
    warning('A and I in A(I) not same shape: did you intend this?')
  end

  % careful, if you have persistence/caching, do these need .copy?
  cmd = [ '(A,mask,n,m) = _ins\n'  ...
          '# transpose b/c SymPy is row-based\n' ...
          'AT = A.T\n' ...
          'maskT = mask.T\n' ...
          'M = sp.Matrix.zeros(m, n)  # row-based\n'  ...
          'j = 0\n' ...
          'for i in range(0,len(A)):\n'  ...
          '    if maskT[i] > 0:\n' ...
          '        M[j] = AT[i]\n'  ...
          '        j = j + 1\n' ...
          'return (M.T,)' ];

  % FIXME: not optimal, but we don't have bool -> sym yet
  if (islogical(I))
    I = double(I);
  end

  % output shape, see logic in comments above
  if (isrow(A))
    n = 1;  m = nnz(I);
  elseif (iscolumn(A))
    n = nnz(I);  m = 1;
  elseif (isrow(I))
    n = 1;  m = nnz(I);
  elseif (iscolumn(I))
    n = nnz(I);  m = 1;
  else
    n = nnz(I);  m = 1;
  end

  Z = python_cmd(cmd, sym(A), sym(I), n, m);
end


%% 2D arrays
%!shared a,b,I
%! b = [1:4]; b = [b; 3*b; 5*b];
%! a = sym(b);
%! I = rand(size(b)) > 0.5;
%!assert(isequal( mat_mask_access(a,I), b(I) ))
%! disp('*** 2 warnings expected: ***');
%! I = I(:);
%!assert(isequal( mat_mask_access(a,I), b(I) ))
%! I = I';
%!assert(isequal( mat_mask_access(a,I), b(I) ))
%! I = logical(zeros(size(b)));
%!assert(isequal( mat_mask_access(a,I), b(I) ))

%% 1D arrays
%!shared r,c,ar,ac,Ir,Ic
%! r = [1:6];
%! ar = sym(r);
%! c = r';
%! ac = sym(c);
%! Ir = rand(size(r)) > 0.5;
%! Ic = rand(size(c)) > 0.5;
%!assert(isequal( mat_mask_access(ar,Ir), r(Ir) ))
%!assert(isequal( mat_mask_access(ac,Ic), c(Ic) ))
%! disp('*** 2 warnings expected: ***');
%!assert(isequal( mat_mask_access(ar,Ic), r(Ic) ))
%!assert(isequal( mat_mask_access(ac,Ir), c(Ir) ))
