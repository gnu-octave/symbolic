function varargout = pretty(x)
%PRETTY   ascii-art/unicode of an expression
%   todo: use_unicode as a global var?, use_unicode=False)
%   todo: wrapping column?

  cmd = [ 'def fcn(_ins):\n'  ...
          '    d = sp.pretty(*_ins, use_unicode=True)\n'  ...
          '    return (d,)\n' ];

  s = python_sympy_cmd (cmd, x);

  if (nargout == 0)
    disp(s)
  else
    varargout = {s};
  end
