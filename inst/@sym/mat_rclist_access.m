function z = mat_rclist_access(A, r, c)
%MAT_RCLIST_ACCESS  private helper routine
%   (r(i),c(i)) specify entries of the matrix A.
%   Returns a column vector of these extracted from A.

  if ~( isvector(r) && isvector(c) && (length(r) == length(c)) )
    error('this routine is for a list of rows and cols');
  end

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (A,rr,cc) = _ins\n'  ...
          '    # 2D access so no transpose for sympy row-based\n' ...
          '    n = len(rr)\n' ...
          '    M = sp.Matrix.zeros(n, 1)\n'  ...
          '    for i in range(0,n):\n'  ...
          '        M[i,0] = A[rr[i],cc[i]]\n'  ...
          '    return (M,)\n' ];

  rr = num2cell(r-1);
  cc = num2cell(c-1);
  z = python_sympy_cmd(cmd, A, rr, cc);
end


%!shared A,B
%! B = [1 2 3; 5 6 7];
%! A = sym(B);
%!assert(isequal(  mat_rclist_access(A,[1 2],[2 3]), [B(1,2); B(2,3)]  ))
