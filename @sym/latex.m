function varargout = latex(x)

  cmd = [ 'def fcn(_ins):\n'  ...
          '    d = sp.latex(*_ins)\n'  ...
          '    return (d,)\n' ];
  s = python_sympy_cmd_raw (cmd, x);
  s = s{1};

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end

