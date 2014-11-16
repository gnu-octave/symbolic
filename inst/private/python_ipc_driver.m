function [A, db] = python_ipc_driver(what, cmd, varargin)
%PYTHON_IPC_DRIVER  Run Python/SymPy command and return strings

  which_ipc = sympref('ipc');

  %% version check
  if exist('octave_config_info', 'builtin')
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

  if (strcmp(lower(which_ipc), 'default'))
    if (exist('popen2') > 1)
      which_ipc = 'popen2';
    else
      which_ipc = 'system';
    end
  end

  switch lower(which_ipc)
    case 'popen2'
      [A, db] = python_ipc_popen2(what, cmd, varargin{:});

    case 'system'
      if (ispc () && (~isunix ()))
        [A, db] = python_ipc_sysoneline(what, cmd, false, varargin{:});
      else
        [A, db] = python_ipc_system(what, cmd, false, varargin{:});
      end

    case 'systmpfile'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_system(what, cmd, true, varargin{:});

    case 'sysoneline'
      %% for debugging, not intended for long-term usage
      [A, db] = python_ipc_sysoneline(what, cmd, false, varargin{:});

    otherwise
      error('invalid ipc mechanism')
  end
