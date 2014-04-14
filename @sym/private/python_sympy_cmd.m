function varargout = python_sympy_cmd(cmd, varargin)
%PYTHON_SYMPY_CMD  Run Python command using Sympy
%   Run a Python SymPy command which takes some octave objects as
%   inputs and return octave objects (including 'sym' objects) as
%   outputs.
%
%   For example:
%
%      [a,b,c,...] = python_sympy_cmd(cmd, x, y, z, ...)
%
%   where x,y,z can be sym objects, strings (char), or scalar doubles.
%   The can also be cell arrays of these items.  Multi-D cell arrays
%   may not work properly.
%
%   'cmd' is a string consisting of python code defining a python
%   function called 'fcn'.  This function takes a list of inputs and
%   return a tuple of outputs.
%
%      cmd = [ ...
%          'def fcn(ins):\n'  ...
%          '    (x,y) = ins\n'  ...
%          '    return (x+y,x-y)\n'  ...
%      ];
%
%   If you have just one return value, you probably want to append
%   an extra comma as in this example:
%      cmd = [ ...
%          'def fcn(ins):\n'  ...
%          '    (x,y) = ins\n'  ...
%          '    return (x+y,)\n'  ...
%      ];
%

% Note: if you don't pass in any sym's, this won't (shouldn't
% anyway) use SymPy.  But it still imports it in that case.  If
% you want to run this w/o having the SymPy package, you'd need
%  to hack a bit.

  A = python_sympy_cmd_raw(cmd, varargin{:});

  % FIXME: for legacy reasons, there were two strings per output,
  % clean this up sometime.
  M = length(A)/2;
  assert(rem(M,1) == 0)
  varargout = cell(1,M);
  for i=1:M
    dontcare = A{2*i-1};
    estr = A{2*i};
    eval(estr)   % creates a variable called tmp, see *ipc* fcns
    varargout{i} = tmp;
  end

  if nargout ~= M
    warning('number of outputs don''t match, was this intentional?')
  end
