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

  cmd = [ '(e,) = _ins\n'  ...
          'r = bool(e.lhs == e.rhs)\n'  ...
          'return (r,)' ];
  r = python_cmd (cmd, p);

  if ~islogical(r)
    disp('logical: cannot happen?  wrong pickle?  Bug?')
    r
    keyboard
    error('unexpected return value')
  end
