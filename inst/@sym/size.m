function [n,m] = size(x)

  n = x.size;
  if (nargout == 2)
    m = n(2);
    n = n(1);
  end

  return


  %% FIXME: the old implementation before sym objs cached size
  cmd = [ 'def fcn(_ins):\n'  ...
          '    x = _ins[0]\n'  ...
          '    #dbout("size of " + str(x))\n'  ...
          '    if x.is_Matrix:\n'  ...
          '        d = x.shape\n'  ...
          '    else:\n'  ...
          '        d = (1,1)\n'  ...
          '    return (d[0],d[1],)\n' ];
  [n,m] = python_sympy_cmd(cmd, x);
  if (nargout <= 1)
    n = [n m];
  end
