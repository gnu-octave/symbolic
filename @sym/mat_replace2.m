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

  cmd = [ 'def fcn(_ins):\n'  ...
          '    AA = _ins[0].copy()\n'  ...
          '    b = _ins[3]\n'  ...
          '    sys.stderr.write("pydebug: " + str(b) + "\\n")\n'  ...
          '    AA[_ins[1],_ins[2]] = b\n'  ...    
          '    sys.stderr.write("pydebug: " + str(AA) + "\\n")\n'  ...      
          '    return (AA,)\n' ];
  z = python_sympy_cmd(cmd, A, r-1, c-1, b);

