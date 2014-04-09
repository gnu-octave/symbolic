function z = mat_replace2(A,subs,b)

  disp('in replace');

  if (length(subs) == 1)
    % special case for linear indices (or teach sympy to use column-based)
    [r, c] = ind2sub (size(A), subs{1});
  elseif (length(subs) == 2)
    r = subs{1};
    c = subs{2};
  else
    error('unknown indexing')
  end

  if (ischar(r) || ischar(c))
    subs
    error('todo: sympy supports : slicing but how to do it programmatically?');
  end
  if ~(isscalar(r) && isscalar(c))
    subs
    error('todo: sympy supports slicing but how to do it programmatically?');
  end

  % Note: we expand by making a new big enough matrix and calling
  % .copyin_matrix.  Easiest as: c[0,0] = b

  cmd = [ 'def fcn(_ins):\n'                                                ...
          '    (A,r,c,b) = _ins\n'                                          ...
          '    AA = sp.Matrix.zeros( max(r+1,A.rows), max(c+1,A.cols) )\n'  ...
          '    #sys.stderr.write("pydebug: " + str(AA) + "\\n")\n'          ...
          '    AA[0,0] = A\n'                                               ...
          '    #sys.stderr.write("pydebug: " + str(b) + "\\n")\n'           ...
          '    AA[r,c] = b\n'                                               ...
          '    #sys.stderr.write("pydebug: " + str(AA) + "\\n")\n'          ...
          '    return (AA,)\n' ];

  z = python_sympy_cmd(cmd, A, r-1, c-1, b);

