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

  % TODO: constructing sym() outside of contructor feels crude,
  % provide a way for constructor to take these inputs?

  for i=1:nargout
    %s = [];
    %s.text = A{2*i-1};
    %s.pickle = A{2*i};
    %s = class(s, 'sym');
    text = A{2*i-1};
    pickle = A{2*i};
    %pickle = undo_string_escapes (A{2*i});
    s = sym(text, pickle);
    varargout{i} = s;
  end

