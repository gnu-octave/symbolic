function varargout = latex(x)

  cmd = [ 'd = sp.latex(*_ins)\n'  ...
          'return (d,)\n' ];

  s = python_cmd (cmd, x);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end
