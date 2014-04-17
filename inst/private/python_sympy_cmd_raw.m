function A = python_sympy_cmd_raw(what, cmd, varargin)
%PYTHON_SYMPY_CMD_RAW  Run SymPy command and return strings

  % todo: way to force a choice here
  if (1==1  &&  exist('popen2', 'builtin'))
    A = python_ipc_popen2(what, cmd, varargin{:});
  else
    A = python_ipc_system(what, cmd, varargin{:});
  end

