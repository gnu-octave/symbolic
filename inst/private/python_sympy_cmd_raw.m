function A = python_sympy_cmd_raw(what, cmd, varargin)
%PYTHON_SYMPY_CMD_RAW  Run SymPy command and return strings

  which_ipc = octsympy_config('ipc');

  switch lower(which_ipc)
    case 'default'
      if (exist('popen2', 'builtin'))
        A = python_ipc_popen2(what, cmd, varargin{:});
      else
        A = python_ipc_system(what, cmd, varargin{:});
      end

    case 'system'
      A = python_ipc_system(what, cmd, varargin{:});

    case 'popen2'
      if (~exist('popen2', 'builtin'))
        warning('You forced popen2 ipc but you don''t have one, trouble ahead');
      end
      A = python_ipc_popen2(what, cmd, varargin{:});

    otherwise
      error('invalid ipc mechanisgm')
  end
