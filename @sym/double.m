function y = double2(x)
%DOUBLE   Convert symbolic to doubles

  cmd = [ 'def fcn(ins):\n'  ...
          '    (x,) = ins\n'  ...
          '    y = sp.N(x,30)\n'  ...
          '    return (y,)\n' ];
  A = python_sympy_cmd_raw(cmd, x);
  y = str2double (A{1});
  if (isnan (y))
    error('conversion failed?');
  end

