function g = subs(f,x,y)
%SUBS   replace symbols in an expression with other expressions
%   f = x*y
%   subs(f, x, y)
%      reppaces x with y
%   subs(f, x, sin(x))
%   subs(f, [x y], [sin(x) 16])
%   todo: thse should be unit tests

    if ~(isscalar(x) && isscalar(y))
      warning('todo: just loop over them and call scalar?')
    end
  

  if (isscalar(f))
    cmd = [ 'def fcn(ins):\n'  ...
            '    (f,x,y) = ins\n'  ...
            '    g = f.subs(x,y)\n'  ...
            '    return (g,)\n' ];
    g = python_sympy_cmd(cmd, f, x, y);

  else
    error('TODO')
  end

