function z = mat_rccross_access(A, r, c)
%MAT_RCCROSS_ACCESS  private helper routine
%   Access entries of A that are the cross product of vectors r and c
%   r and c could be strings.  Namely ':' and ':'
%
%   r and c could contain duplicates.  This is one reason by this
%   code doesn't easily replace mat_rclist_access().

  if ((r == ':') && (c == ':'))
    z = A;
    return
  end

  %if both expressible as py slices...
  % FIXME: Could optimize these cases

  [n,m] = size(A);
  if (r == ':')
    r = 1:n;
  elseif ischar(r)
    error('unknown row?')
  end
  if (c == ':')
    c = 1:m;
  elseif ischar(c)
    error('unknown column?')
  end

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (A,rr,cc) = _ins\n'  ...
          '    M = sp.Matrix.zeros(len(rr), len(cc))\n'  ...
          '    for i in range(0,len(rr)):\n'  ...
          '        for j in range(0,len(cc)):\n'  ...
          '            M[i,j] = A[rr[i],cc[j]]\n'  ...
          '    return (M,)\n' ];

  rr = num2cell(r-1);
  cc = num2cell(c-1);
  z = python_sympy_cmd(cmd, A, rr, cc);

  % FIXME: here's some code could be used for slices
  if (1==0)
  cmd = [ 'def fcn(_ins):\n'  ...
          '    A = _ins[0]\n'  ...
          '    r = slice(_ins[1],_ins[2])\n'  ...
          '    c = slice(_ins[3],_ins[4])\n'  ...
          '    M = A[r,c]\n'  ...
          '    return (M,)\n' ];
  z = python_sympy_cmd(cmd, A, r1-1, r2, c1-1, c2);
  end
end


%!shared A,B
%! B = [1 2 3 4; 5 6 7 9; 10 11 12 13];
%! A = sym(B);
%!assert(isequal(  mat_rccross_access(A,[1 3],[2 3]), B([1 3], [2 3])  ))
%!assert(isequal(  mat_rccross_access(A,1,[2 3]), B(1,[2 3])  ))
%!assert(isequal(  mat_rccross_access(A,[1 2],4), B([1 2],4)  ))
%!assert(isequal(  mat_rccross_access(A,[2 1],[4 2]), B([2 1],[4 2])  ))
%!assert(isequal(  mat_rccross_access(A,[],[]), B([],[])  ))
