function varargout = pretty(x)

  cmd = [ 'def fcn(_ins):\n'  ...
          '    #sys.stderr.write(str(*_ins))\n'  ...
          '    d = sp.pretty(*_ins)\n'  ...
          '    return (d,)\n' ];
  s = python_sympy_cmd_raw (cmd, x);
  s = s{1};

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end


