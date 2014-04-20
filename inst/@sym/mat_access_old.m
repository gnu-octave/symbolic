function z = mat_access_old(A, subs)
%private

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

  % todo: in general we probably need .copy()
  cmd = [ 'A = _ins[0]\n'  ...
          'M = A[_ins[1],_ins[2]]\n'  ...
          'return (M,)' ];

  z = python_cmd(cmd, A, r-1, c-1);

