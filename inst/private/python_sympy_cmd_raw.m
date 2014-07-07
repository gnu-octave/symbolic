function A = python_sympy_cmd_raw(what, cmd, varargin)
%PYTHON_SYMPY_CMD_RAW  Run SymPy command and return strings

  which_ipc = octsympy_config('ipc');

  %% version check
  if exist('octave_config_info', 'builtin');
    if (compare_versions (OCTAVE_VERSION (), '3.6.4', '<'))
      fprintf(['\n********************************************************************\n' ...
               'Your Octave version is %s but Octsympy is currently untested on\n' ...
               'anything before 3.6.4.  For example, persistent variables don''t\n' ...
               'seem to work properly on 3.2.4.\n\n'], ...
              OCTAVE_VERSION ())
      warning('Old Octave version detected: probably trouble ahead!')
      fprintf('\n********************************************************************\n\n')
      fflush(stdout);
    end
  end

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
      error('invalid ipc mechanism')
  end
