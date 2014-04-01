function varargout = pretty(x)
%PRETTY   ascii-art/unicode of an expression
%   todo: use_unicode as a global var?, use_unicode=False)
%   todo: wrapping column?

  cmd = [ 'def fcn(_ins):\n'  ...
          '    #sys.stderr.write("pydebug: " + str(_ins) + "\\n")\n'  ...
          '    d = sp.pretty(*_ins)\n'  ...
          '    return (d,)\n' ];
  s = python_sympy_cmd_raw (cmd, x);
  s = s{1};

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end


