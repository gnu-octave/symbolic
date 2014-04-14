function A = python_ipc_popen2(cmd, varargin)

  persistent fin fout pid

  sbtag='<output_block>';
  stag='<output_item>';
  etag='</output_item>';
  ebtag='</output_block>';

  headers = python_header();

  if isempty(pid)
      disp('we have popen2: opening new pipe for two-way ipc')
      [fin, fout, pid] = popen2 ('/bin/python','-i')
      %[fin, fout, pid] = popen2 ('/home/cbm/mydebugpython.sh')
      %[fin, fout, pid] = popen2 ('/bin/python','-i -c "x=1; print x"')
      fputs (fin, headers);
      fprintf (fin, 'print "hello"\n');
      fflush(fin);
      %sleep(2)
      %ab = fgets(fout)
      %disp(ab)
      %keyboard
      %disp('paused'); pause
      % todo print a block and read it to make sure we're live
    %else
      %disp('we have existing popen2 pipe')
      %fin, fout,pid
    end



  % wrap loading of vars in a big try catch block
  % todo: s = appendline(s, indent, str, varargin)
  % append one newline by default
  % todo this is not just fprintf b/c of the no-open case?

  %% load all the inputs into python as pickles
  s = python_copy_vars_to('ins', varargin{:});

  fputs (fin, s);
  fflush(fin);
  %disp('paused before read'); pause
  out = readblock(fout, sbtag, ebtag);
  A = extractblock(out);
  if ~(strfind(A{1}, 'successful'))
    error('failed to import variables to python?')
  end

  %% the actual command
  % todo: wrap this in try catch too
  s = sprintf('%s\n\n', cmd);
  s = sprintf('%sout = fcn(ins)\n\n', s);

  %debug
  %s = sprintf('%sprint out\n\n', s);

  %% output
  s2 = python_copy_vars_from('out');
  s = [s s2];

  fputs (fin, s);
  fflush(fin);
  %disp('paused before read'); pause
  out = readblock(fout, sbtag, ebtag);
  A = extractblock(out);
