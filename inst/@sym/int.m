function z = int(f,x,a,b)
%INT   Symbolic integration
%   The definite integral to integrate an expression 'f' with respect
%   to variable 'x' from x=0 to x=2 is:
%      F = int(f, x, 0, 2);
%   Indefinite integral:
%      F = int(f, x);
%      F = int(f);

  if nargin == 1
    cmd = [ '(f,) = _ins\n'  ...
            'd = sp.integrate(f)\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f));

  elseif nargin == 2
    cmd = [ '(f,x) = _ins\n'  ...
            'd = sp.integrate(f, x)\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f), sym(x));

  elseif nargin == 4
    cmd = [ '(f,x,a,b) = _ins\n'  ...
            'd = sp.integrate(f, (x, a, b))\n'  ...
            'return (d,)' ];
    z = python_cmd (cmd, sym(f), sym(x), sym(a), sym(b));
  end

