function [A, db] = python_ipc_driver(what, cmd, varargin)
%PYTHON_IPC_DRIVER  Run Python/SymPy command and return strings

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
        [A, db] = python_ipc_popen2(what, cmd, varargin{:});
      else
        [A, db] = python_ipc_system(what, cmd, false, varargin{:});
      end

    case 'system'
      [A, db] = python_ipc_system(what, cmd, false, varargin{:});

    case 'systmpfile'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_system(what, cmd, true, varargin{:});

    case 'sysoneline'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_sysoneline(what, cmd, false, varargin{:});

    case 'popen2'
      if (~exist('popen2', 'builtin'))
        warning('You forced popen2 ipc but you don''t have one, trouble ahead');
      end
      [A, db] = python_ipc_popen2(what, cmd, varargin{:});

    otherwise
      error('invalid ipc mechanism')
  end
