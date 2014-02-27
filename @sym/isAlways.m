function r = isAlways(p)
%ISALWAYS   Test is expression is mathematically true
%   Example:
%      isAlways(x*(1+y) == x+x*y)
%   which returns 'true', in contrast with:
%      logical(x*(1+y) == x+x*y)
%   which returns 'false'.
%
%   See also, logical()
%
%   TODO: trigsimp() etc etc?

  true_pickle = sprintf('I01\n.');
  false_pickle = sprintf('I00\n.');

  cmd = [ 'def fcn(ins):\n'  ...
          '    (p,) = ins\n'  ...
          '    r = sp.simplify(p) == 0\n'  ...
          '    return (r,)\n' ];
  z = python_sympy_cmd (cmd, p);

  if (strcmp(z.pickle, true_pickle))
    r = true;
  elseif (strcmp(z.pickle, false_pickle))
    r = false;
  else
    keyboard
    error('cannot happen?  wrong pickle?  Bug?')
  end

