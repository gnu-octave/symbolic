function [A, out] = python_ipc_popen2(what, cmd, varargin)
% "out" provided for debugging

  persistent fin fout pid

  py_startup_timeout = 30;  % seconds

  if (strcmp(what, 'reset'))
    if (~isempty(pid))
      disp('Closing the Python pipe...');
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

  vstr = sympref('version');

  if isempty(pid)
    disp(['OctSymPy v' vstr ': this is free software without warranty, see source.'])
    disp('Initializing communication with SymPy using a popen2() pipe.')

    pyexec = sympref('python');
    if (isempty(pyexec))
      if (ispc () && ! isunix ())
        % Octave popen2 on Windows can't tolerate stderr output
        % https://savannah.gnu.org/bugs/?43036
        disp(['Detected a Windows system: using "mydbpy.bat", workaround Octave bug'])
        pyexec = 'mydbpy.bat';
      else
        pyexec = 'python';
      end
    end
    % perhaps the the '-i' is not always wanted?
    [fin, fout, pid] = popen2 (pyexec, '-i');

    disp('Python started: some output may appear before your prompt returns.')
    fprintf('Technical details: fin = %d, fout = %d, pid = %d.\n\n', fin, fout, pid)
    fflush (stdout);

    if (pid < 0)
      error('popen2() failed');
    end

    % repeated from python_header.py: kill prompt ASAP
    fprintf (fin, 'import sys\nsys.ps1 = ""; sys.ps2 = ""\n\n')
    fflush(fin);
    %sleep(0.05); %disp('')

    headers = python_header();
    fputs (fin, headers);
    fprintf (fin, '\n\n');
    %fflush(fin);
    %sleep(0.05); disp('');

    % print a block then read it to make sure we're live
    fprintf (fin, 'octoutput_drv("SymPy communication channel established")\n\n');
    fflush(fin);
    % if any exceptions in start-up, we probably get those instead
    [out, err] = readblock(fout, py_startup_timeout);
    if (err)
      error('OctSymPy:python_ipc_popen2:timeout', ...
        'ipc_popen2: something wrong? timed out starting python')
    end
    A = extractblock(out);
    if (isempty(strfind(A, 'established')))
      A
      out
      error('ipc_popen2: something has gone wrong in starting python')
    else
      disp(['ipc_popen2: ' A{1}])
    end
  end


  newl = sprintf('\n');

  %% load all the inputs into python as pickles
  % they will be in the list '_ins'
  % there is a try-except block here, sends a block if sucessful
  s = python_copy_vars_to('_ins', true, varargin{:});

  fputs (fin, s);
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

  s = [s s2];

  fputs (fin, s);
  fflush(fin);
  [out, err] = readblock(fout, inf);
  if (err)
    error('OctSymPy:python_ipc_popen2:cmderr', ...
      'ipc_popen2: cmd error? read block returned error');
  end
  A = extractblock(out);
