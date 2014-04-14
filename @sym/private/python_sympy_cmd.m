function varargout = python_sympy_cmd(cmd, varargin)
%PYTHON_SYMPY_CMD  Run SympPy command and return symbolic expressions
%   Run a Python SymPy command which takes some 'sym' objects as
%   inputs and return 'sym' objects as outputs.
%
%   For example:
%
%      [a,b,c,...] = python_sympy_cmd(cmd, x, y, z, ...)
%
%   where x,y,z are of class 'sym'.  'cmd' is a string consisting
%   of python code to define a python function called 'fcn'.  This
%   function takes a list of inputs and return a tuple of outputs.
%
%      cmd = [ ...
%          'def fcn(ins):\n'  ...
%          '    (x,y) = ins\n'  ...
%          '    return (x+y,x-y)\n'  ...
%      ];
%
%

  A = python_sympy_cmd_raw(cmd, varargin{:});

  M = length(A)/2;
  assert(rem(M,1) == 0)
  varargout = cell(1,M);
  for i=1:M
    text = A{2*i-1};
    estr = A{2*i};
    eval(estr)   % creates a variable called tmp, see *ipc* fcns
    varargout{i} = tmp;
  end

  if nargout ~= M
    warning('number of outputs don''t match, was this intentional?')
  end
