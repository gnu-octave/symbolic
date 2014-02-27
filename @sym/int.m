function z = int(f,x,a,b)
%INT   Symbolic integration
%   The definite integral to integrate an expression 'f' with respect
%   to variable 'x' from x=0 to x=2 is:
%      F = int(f, x, 0, 2);
%   Indefinite integral:
%      F = int(f, x);
%      F = int(f);

  if nargin == 1
    cmd = [ 'def fcn(ins):\n'  ...
            '    (f,) = ins\n'  ...
            '    d = sp.integrate(f)\n'  ...
            '    return (d,)\n' ];
    z = python_sympy_cmd (cmd, f);

  elseif nargin == 2
    cmd = [ 'def fcn(ins):\n'  ...
            '    (f,x) = ins\n'  ...
            '    d = sp.integrate(f, x)\n'  ...
            '    return (d,)\n' ];
    z = python_sympy_cmd (cmd, f, x);

  elseif nargin == 4
    a = sym(a);
    b = sym(b);
    cmd = [ 'def fcn(ins):\n'  ...
            '    (f,x,a,b) = ins\n'  ...
            '    d = sp.integrate(f, (x, a, b))\n'  ...
            '    return (d,)\n' ];
    z = python_sympy_cmd (cmd, f, x, a, b);
  end

