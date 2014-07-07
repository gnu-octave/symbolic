function A = python_ipc_popen2(what, cmd, varargin)

  persistent fin fout pid

  if (strcmp(what, 'reset'))
    disp('Closing the Python pipe...');
    pid = [];
    if (~isempty(fin))
      t = fclose(fin); fin = [];
      A = (t == 0);
    else
      A = true;
    end
    if (~isempty(fout))
      t = fclose(fout); fout = [];
      A = A && (t == 0);
    end
    return
  end

  if ~(strcmp(what, 'run'))
    error('unsupported command')
  end

  tag = ipc_misc_params();

  if isempty(pid)
    disp('##')
    disp('##  OctSymPy: Initializing SymPy communication...')
    disp('##');
    disp('##  We have popen2(): opening a new pipe for two-way IPC with SymPy...')
    disp('##');

    [fin, fout, pid] = popen2 ('python','-i');

    fprintf('##  Technical info: fin = %d, fout = %d, pid = %d\n', fin, fout, pid)
    disp('##');
    disp('##  Python should be starting, you may see a few lines of output')
    disp('##  from it which can probably be ignored until your prompt returns.')
    disp('##')
    fflush (stdout);

    if (pid < 0)
      error('popen2() failed');
    end

    headers = python_header();
    fputs (fin, headers);
    fprintf (fin, 'print "hello"\n');
    fflush(fin);
    % todo print a block and read it to make sure we're live
  end


  newl = sprintf('\n');

  % wrap loading of vars in a big try catch block
  % todo: s = appendline(s, indent, str, varargin)
  % append one newline by default
  % todo this is not just fprintf b/c of the no-open case?

  %% load all the inputs into python as pickles
  % they will be in the list '_ins'
  s = python_copy_vars_to('_ins', varargin{:});

  fputs (fin, s);
  fflush(fin);
  %disp('paused before read'); pause
  out = readblock(fout, tag.block, tag.endblock);
  A = extractblock(out, tag.item, tag.enditem);
  if (isempty(strfind(A{1}, 'successful')))
    error('failed to import variables to python?')
  end

  %% the actual command
  % this will do something with _ins and produce _outs
  % FIXME: wrap this in try catch too
  s = [cmd newl newl];

  %% output
  s2 = python_copy_vars_from('_outs');
  s = [s s2];

  fputs (fin, s);
  fflush(fin);
  %disp('paused before read'); pause
  out = readblock(fout, tag.block, tag.endblock);
  A = extractblock(out, tag.item, tag.enditem);
