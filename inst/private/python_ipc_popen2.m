function [A, out] = python_ipc_popen2(what, cmd, varargin)
% "out" provided for debugging

  persistent fin fout pid

  py_startup_timeout = 30;  % seconds

  verbose = ~sympref('quiet');

  if (strcmp(what, 'reset'))
    if (~isempty(pid))
      if (verbose)
        disp('Closing the Python pipe...');
      end
    end
    if (~isempty(fin))
      t = fclose(fin); fin = [];
      waitpid(pid);
      pid = [];
      A = (t == 0);
    else
      A = true;
    end
    if (~isempty(fout))
      t = fclose(fout); fout = [];
      A = A && (t == 0);
    end
    out = [];
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  newl = sprintf('\n');

  if isempty(pid)
    if (verbose)
      fprintf('OctSymPy v%s: this is free software without warranty, see source.\n', ...
              sympref('version'))
      disp('Initializing communication with SymPy using a popen2() pipe.')
    end
    pyexec = sympref('python');
    if (isempty(pyexec))
      if (ispc() && ~isunix())
        % Octave popen2 on Windows can't tolerate stderr output
        % https://savannah.gnu.org/bugs/?43036
        if (verbose)
          disp('Detected Windows: using "winwrapy.bat" to workaround Octave bug #43036')
        end
        pyexec = 'winwrapy.bat';
      else
        pyexec = 'python';
      end
    end
    % perhaps the the '-i' is not always wanted?
    [fin, fout, pid] = popen2 (pyexec, '-i');

    if (verbose)
      fprintf('Some output from the Python subprocess (pid %d) might appear next.\n', pid)
      %fprintf('Technical details: fin = %d, fout = %d, pid = %d.\n', fin, fout, pid)
    end
    fflush (stdout);

    if (pid < 0)
      error('popen2() failed');
    end

    % repeated from python_header.py: kill prompt ASAP
    fprintf (fin, 'import sys\nsys.ps1 = ""; sys.ps2 = ""\n\n')
    fflush(fin);

    headers = python_header();
    fputs (fin, headers);
    fprintf (fin, '\n\n');
    %fflush(fin);

    % print a block then read it to make sure we're live
    fprintf (fin, 'octoutput_drv(("Communication established.", sympy.__version__, sys.version))\n\n');
    fflush(fin);
    % if any exceptions in start-up, we probably get those instead
    [out, err] = readblock(fout, py_startup_timeout);
    if (err)
      error('OctSymPy:python_ipc_popen2:timeout', ...
        'ipc_popen2: something wrong? timed out starting python')
    end
    A = extractblock(out);
    fprintf('\n');  % needed even if not verbose
    if (isempty(strfind(A{1}, 'established')))
      A
      out
      error('ipc_popen2: something has gone wrong in starting python')
    else
      if (verbose)
        disp(['OctSymPy: ' A{1} '  SymPy v' A{2} '.']);
        % on unix we're seen this on stderr
        if (ispc() && ~isunix())
          disp(['Python ' strrep(A{3}, newl, '')])
        end
      end
    end
  end



  %% load all the inputs into python as pickles
  % they will be in the list '_ins'
  % there is a try-except block here, sends a block if sucessful
  loc = python_copy_vars_to('_ins', true, varargin{:});
  write_lines(fin, loc, true);
  fflush(fin);
  [out, err] = readblock(fout, inf);
  if (err)
    error('OctSymPy:python_ipc_popen2:xfer', ...
      'ipc_popen2: xfer vars: something wrong? timed out?')
  end

  % could extractblock here, but just search for keyword instead
  if (isempty(strfind(out, 'successful')))
    out
    A = extractblock(out)
    error('ipc_popen2: failed to send variables to python?')
  end

  %% The actual command
  % cmd will be a snippet of python code that does something
  % with _ins and produce _outs.
  s = python_format_cmd(cmd);


  %% output, or perhaps a thrown error
  s2 = python_copy_vars_from('_outs');

  write_lines(fin, s, true)
  write_lines(fin, s2, true)

  fflush(fin);
  [out, err] = readblock(fout, inf);
  if (err)
    error('OctSymPy:python_ipc_popen2:cmderr', ...
      'ipc_popen2: cmd error? read block returned error');
  end
  A = extractblock(out);
