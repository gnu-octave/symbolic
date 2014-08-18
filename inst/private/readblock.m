function A = readblock(fout, tagblock, tagendblock, timeout)
%private function

  % FIXME: needs timeout feature
  if (nargin < 4)
    timeout = inf;
  end

  % how long to wait before displaying "Waiting..."
  wait_disp_thres = 2.0;

  EAGAIN = errno ('EAGAIN');
  % Windows emits this when pipe is waiting (see
  % octave/libinterp/corefcn/syscalls.cc test code)
  EINVAL = errno ('EINVAL');
  done = false;
  started = false;
  nwaits = 0;
  dispw = false;
  waited = 0;

  fclear (fout);  % otherwise, fails on next call

  do
    if (ispc () && ! isunix ())
      errno (0);  % win32, see syscalls.cc test code
    end
    s = fgets (fout);
    if (ischar (s))
      %fputs (stdout, s);
      if (started)
        A = [A s];
      end
      % here is the <start block> tag, so start recording output
      if (strncmp(s, tagblock, length(tagblock)))
        started = true;
        A = s;
      end
      % if we see the end tag, we're done
      if (strncmp(s, tagendblock, length(tagendblock)))
        done = true;
      end

    elseif (errno() == EAGAIN || errno() == EINVAL)
      waitdelta = exp(nwaits/10)/1e4;
      waited = waited + waitdelta;
      if waited <= wait_disp_thres
        %fprintf(stdout, 'W'); % debugging, in general do nothing
      elseif (~dispw)
        fprintf(stdout, 'Waiting...')
        dispw = true;
      else
        fprintf(stdout, '.')
      end
      fclear (fout);
      %if (ispc () && ! isunix ())
      %errno (0);   % maybe can do this on win32?
      %end
      sleep (waitdelta);
      nwaits = nwaits + 1;
    else
      % FIXME: win32 can get here with errno 0, still need to wait?
      % FIXME: need to separate the treatment from other unexpected errno?
      errno ()
      s
      warning ('OctSymPy:readblock:invaliderrno', 'Failed to read python output, perhaps an error in the command?')
    end
    %disp('paused'); pause

    if (waited > timeout)
      warning('OctSymPy:readblock:timeout', ...
        sprintf('readblock: timeout of %g exceeded, breaking out', timeout));
      % FIXME: need a success/fail flag?  what to return here?
      A = [A '\nFAILED TIMEOUT\n'];
      break
    end
  until (done)

  if (dispw)
    fprintf(stdout, '\n')
  end
  %fclose (fout);
  %waitpid (pid);

