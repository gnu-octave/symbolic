function z = mat_replace(A, subs, b)
%MAT_REPLACE  private helper routine

  if ( (length(subs) == 1) && (islogical(subs{1})) )
    %% A(logical) = B
    z = mat_mask_asgn(A, subs{1}, b);
    return

  elseif (length(subs) == 1)
    % can use a single index to grow a vector, so we carefully deal with
    % vector vs linear index to matrix (not required for access)
    [n,m] = size(A);
    if (n == 0 || n == 1)
      r = 1;  c = subs{1};
    elseif (m == 1)
      r = subs{1};  c = 1;
    else
      % special case for linear indices (or teach sympy to use column-based)
      [r, c] = ind2sub (size(A), subs{1});
    end

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
          '    if not A.is_Matrix:\n'                                       ...
          '        A = sp.Matrix([[A]])\n'                                  ...
          '    AA = sp.Matrix.zeros( max(r+1,A.rows), max(c+1,A.cols) )\n'  ...
          '    AA[0,0] = A\n'                                               ...
          '    AA[r,c] = b\n'                                               ...
          '    return (AA,)\n' ];

  z = python_sympy_cmd(cmd, A, r-1, c-1, b);

