function g = subs(f,x,y)
%SUBS   replace symbols in an expression with other expressions
%   f = x*y
%   subs(f, x, y)
%      replaces x with y
%   subs(f, x, sin(x))
%   subs(f, {x y}, {sin(x) 16})
%   todo: allow [ ] arrays too.

  %if ~(isscalar(x) && isscalar(y))
  %  warning('todo: multiple subs: just looping')
  if (iscell(x) && iscell(y))
    assert_same_shape(x,y)
    for i = 1:numel(x)
      f = subs(f, x{i}, y{i});
    end
    g = f;
    return
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

