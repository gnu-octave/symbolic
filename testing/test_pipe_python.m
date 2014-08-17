%% basic python with popen2 test
%

more off

EAGAIN = errno ('EAGAIN')
EINVAL = errno ('EINVAL')

disp('** calling popen2')

[in, out, pid] = popen2 ('python', '-i')
%[in, out, pid] = popen2 ('n:\win32\py.exe')
assert(pid > 0)

sleep(0.1)
fprintf('\n')

% this will make the correct newline on win and unix
newl = sprintf('\n');

r = fputs (in, ['a = 42; print((a,a,a))' newl newl]);
assert(r == 0)

%% test loading modules
%r = fputs (in, ['import sympy' newl newl]);
%assert(r == 0)

r = fputs (in, ['a = "test"; print(a)' newl newl]);
assert(r == 0)

r = fputs (in, ['a = 43; print((a,a,a))' newl newl]);
assert(r == 0)

%% other things that work
r = fputs (in, sprintf('a = "weee"; print(a)\n\n'));
fprintf (in, 'a = "weee"; print(a)\n\n')
r = fputs (in, [newl newl]);
assert(r == 0)

fprintf (in, 'print("** LAST input **")\n\n')
fprintf (in, 'print("** LAST input **")\n\n')
r = fputs (in, [newl newl]);

%% Flush input
% necessary (tested on GNU/Linux) if last input is fprintf, rather
% than fputs.
r = fflush(in);  assert(r == 0)

%% Issue whether we close before reading from the pipe
% need to close it later for proper interactivity.
%r = fclose (in);  assert(r == 0)

sleep (0.1);

fprintf('\n**** Starting to read from pipe ****\n')
done = false;

num_again = 0;
while(1)
  if (ispc() && ~isunix())
    %% reset errno before the syscall, harmful on Linux?
    % what about Mac OS X?
    errno(0)   % see octave syscall.cc test on windows
  end
  s = fgets (out);
  if (ischar (s))
    fputs (stdout, s);
  elseif (errno() == EINVAL)
    fclear (out);
    errno(0);   % reset errno, is this sufficient for win32?
    sleep (0.1);
    disp('waiting (on win32)')
    num_again++;
    assert (ispc() && ~isunix())
  elseif (errno() == EAGAIN)
    fclear(out);
    errno(0);   % not required on posix but harmless?
    sleep(0.1);
    disp('waiting (on posix)')
    num_again++;
    %assert (~ispc() && isunix())
  else
    warning('fgets returned non-string but unexpected errno...')
    s
    errno
    sleep(0.1);
    num_again++;
  end
  if (num_again > 25)
    disp('25 waits, breaking out')
    break
  end
end

r = fclose (in);  assert(r == 0)
r = fclose (out);  assert(r == 0)
waitpid (pid);
