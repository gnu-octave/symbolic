function z = mat_rclist_asgn(A, r, c, B)
%MAT_RCLIST_ASGN  private helper routine
%   (r(i),c(i)) specify entries of the matrix A.
%   We execute A(r(i),c(i)) = B(i)
%   Note B is accessed with linear indexing.
%   Note B might be a scalar, used many times.
%   A might need to get bigger, andwill be padded with zeros.

  if ~( isvector(r) && isvector(c) && (length(r) == length(c)) )
    error('this routine is for a list of rows and cols');
  end

  if (numel(B) == 1)
    B = B*ones(nnz(I),1);
  end
  if (length(r) ~= numel(B))
    error('not enough/too much in B')
  end

  % Note: we expand by making a new big enough matrix and calling
  % .copyin_matrix.  Easiest as: new[0,0] = old

  cmd = [ '(A,r,c,B) = _ins\n'  ...
          '# B linear access fix, transpose for sympy row-based\n' ...
          'if not B.is_Matrix:\n'  ...
          '    B = sp.Matrix([[B]])\n'  ...
          'BT = B.T\n' ...
          '# copy of A, expanded and padded with zeros\n' ...
          'if not A.is_Matrix:\n'  ...
          '    n = max( max(r)+1, 1 )\n' ...
          '    m = max( max(c)+1, 1 )\n'  ...
          'else:\n' ...
          '    n = max( max(r)+1, A.rows )\n' ...
          '    m = max( max(c)+1, A.cols )\n'  ...
          'AA = sp.Matrix.zeros(n, m)\n'  ...
          'AA[0,0] = A\n' ...
          'for i in range(0,len(r)):\n'  ...
          '    AA[r[i],c[i]] = BT[i]\n'  ...
          'return (AA,)' ];

  rr = num2cell(r-1);
  cc = num2cell(c-1);
  z = python_cmd (cmd, A, rr, cc, B);


  % a simpler earlier version, but onbly for scalar r,c
  cmd = [ 'def fcn(_ins):\n'                                                ...
          '    (A,r,c,b) = _ins\n'                                          ...
          '    if not A.is_Matrix:\n'                                       ...
          '        A = sp.Matrix([[A]])\n'                                  ...
          '    AA = sp.Matrix.zeros( max(r+1,A.rows), max(c+1,A.cols) )\n'  ...
          '    AA[0,0] = A\n'                                               ...
          '    AA[r,c] = b\n'                                               ...
          '    return (AA,)\n' ];
end


%!shared A,B
%! B = [1 2 3; 4 5 6];
%! A = sym(B);
%!test
%! C = B; C([1 6]) = [8 9];
%! assert(isequal(  mat_rclist_asgn(A,[1 2],[1 3],sym([8 9])), C  ))

%% rhs scalar
%!test
%! C = B; C([1 6]) = 88;
%! assert(isequal(  mat_rclist_asgn(A,[1 2],[1 3],sym(88)), C  ))

%% If rhs is not a vector, make sure col-based access works
%!test
%! rhs = [18 20; 19 21];
%! C = B; C([1 2 3 4]) = rhs;
%! D = mat_rclist_asgn(A,[1 2 1 2],[1 1 2 2],sym(rhs));
%! assert(isequal( D, C ))

%% Growth
%!test
%! C = B; C(1,5) = 10;
%! D = mat_rclist_asgn(A,1,5,sym(10));
%! assert(isequal( D, C ))

