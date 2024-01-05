%% Copyright (C) 2014-2015, 2024 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

function [A, err] = readblock(fout, timeout)
%private function: read one block

  % how long to wait before displaying "Waiting..."
  wait_disp_thres = 8.0;

  tagblock = '<output_block>';
  tagendblock = '</output_block>';
  err = false;

  EAGAIN = errno ('EAGAIN');
  % Windows emits this when pipe is waiting (see
  % octave/libinterp/corefcn/syscalls.cc test code)
  EINVAL = errno ('EINVAL');
  done = false;
  started = false;
  nwaits = 0;
  lastdot = 0;
  skip = 0;
  dispw = false;
  start = time();

  fclear (fout);  % otherwise, fails on next call

  do
    if (ispc () && (~isunix ()))
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

    elseif (errno () == EAGAIN || errno () == EINVAL || errno () == 0)
      if (errno () >= 0)
        warning ('OctSymPy:readblock:invaliderrno', ...
		 'error with errno = 0: shouldn''t that be impossible?')
      end
      % with these coefficients, we check about 90 times before the display
      % starts at 8 seconds; at that time the waitdelta is approx 1 second.
      % We cap the waiting at 1 second (Issue #1255).
      waitdelta = min (1, exp (nwaits/10)/1e4);
      if (time() - start <= wait_disp_thres)
        % no-op
      elseif (~dispw)
        fprintf (stdout, 'Waiting...')
        dispw = true;
      else
        if nwaits - skip >= lastdot
          fprintf (stdout, '.')
          lastdot = nwaits;
          % Don't draw every second; increase the number of seconds to skip
          skip = skip + 1;
        end
      end
      fclear (fout);
      %if (ispc () && (~isunix ()))
      %errno (0);   % maybe can do this on win32?
      %end
      pause (waitdelta);
      nwaits = nwaits + 1;
    else
      warning ('OctSymPy:readblock:invaliderrno', ...
        sprintf('readblock: s=%d, errno=%d, perhaps error in the command?', s, errno()))
      pause(0.1)  % FIXME; replace with waitdelta etc
    end
    %disp('paused'); pause

    if (time() - start > timeout)
      warning('OctSymPy:readblock:timeout', ...
        sprintf('readblock: timeout of %g exceeded, breaking out', timeout));
      if (started)
        disp('output so far:')
        A
      else
        disp('no output so far')
        A = '';
      end
      A = [A '\nFAILED TIMEOUT\n'];
      err = true;
      break
    end
  until (done)

  if (dispw)
    fprintf(stdout, '\n')
  end
  %fclose (fout);
  %waitpid (pid);

