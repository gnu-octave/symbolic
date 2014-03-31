function r = logical(p)
%LOGICAL   Test if expression is "structurally" true
%   todo: should be used with if/else flow ctrl
%   Example:
%      logical(x*(1+y) == x*(y+1))
%   return 'true'
%      logical(x == y)
%   return 'false'
%
%   Example:
%      isAlways(x*(1+y) == x+x*y)
%   which returns 'true', in contrast with:
%      logical(x*(1+y) == x+x*y)
%   which returns 'false'.
%
%   See also, 'eq' (i.e., '==') and 'isAlways'.

  if ~(isscalar(p))
    warning('logical not implemented for arrays (?) todo?');
  end

  true_pickle = sprintf('I01\n.');
  false_pickle = sprintf('I00\n.');

  cmd = [ 'def fcn(_ins):\n'  ...
          '    (e,) = _ins\n'  ...
          '    r = bool(e.lhs == e.rhs)\n'  ...
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
  %disp('called logical')
