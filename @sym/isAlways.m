function r = isAlways(p)
%ISALWAYS   Test is expression is mathematically true
%   Example:
%      syms x
%      isAlways(x*(1+y) == x+x*y)
%   which returns 'true', in contrast with:
%      logical(x*(1+y) == x+x*y)
%   which returns 'false'.
%
%   Note using this in practice often falls back to @logical/isAlways
%   (which we provide, essentially a no-op), is case the result has
%   already simplified to double == double.  For example:
%      syms x
%      isAlways (sin(x) - sin(x) == 0)
%
%   TODO: trigsimp() etc etc?

  true_pickle = sprintf('I01\n.');
  false_pickle = sprintf('I00\n.');

  cmd = [ 'def fcn(ins):\n'  ...
          '    (p,) = ins\n'  ...
          '    r = sp.simplify(p.lhs-p.rhs) == 0\n'  ...
          '    return (r,)\n' ];
  z = python_sympy_cmd (cmd, p);

  if (strcmp(z.pickle, true_pickle))
    r = true;
  elseif (strcmp(z.pickle, false_pickle))
    r = false;
  else
    keyboard
    error('Bug!  Perhaps wrong true/false pickles?')
  end

