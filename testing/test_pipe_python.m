%% basic python with popen2 test
%

more off

EAGAIN = errno ('EAGAIN')
EINVAL = errno ('EINVAL')

disp('** calling popen2')

%[in, out, pid] = popen2 ('python', '-i')
%[in, out, pid] = popen2 ('n:\win32\py.exe', '-i')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\winwrapy.bat')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\busybox.exe', 'cat')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-i -c "a=42;print(a);print(a,a)"')

% works on win32:
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\busybox.exe', 'cat')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\busybox.exe', {'cat'})
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe')
% (but needs to fclose first!)
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-V')

% does not work:
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\busybox.exe cat')

% should work but does not:
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-i')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-c print(42)')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-c print(42)')

% testing
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-i')
%[in, out, pid] = popen2 ('n:\win32\octsympy.git\testing\py.exe', '-c print(42)')
%args = {'-c' 'print(42)'};
Targs = {'-c' '"print(66);a=66;print((a,a,a,a))"'};
%args = {'-i' '-u' '--help'};
args = {'-u'};
[in, out, pid] = popen2 ('py.exe', args)
assert(pid > 0)

close_first = true

sleep(0.1)
fprintf('\n')

% this will make the correct newline on win and unix
newl = sprintf('\n');

newl2 = "\r\n";

r = fputs (in, ['a = 42; print((a,a,a))' newl2 newl2]);
assert(r == 0)

%% test loading modules
%r = fputs (in, ['import sympy' newl newl]);
%assert(r == 0)

r = fputs (in, ['a = "test"; print(a)' newl newl]);
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
sleep (0.1);
r = fflush(in);  assert(r == 0)
sleep (0.1);
r = fflush(in);  assert(r == 0)

%% Issue whether we close before reading from the pipe
% need to close it later for proper interactivity.
if (close_first)
  disp('closing "in" before reading back')
  r = fclose (in);  assert(r == 0);
end


fprintf('\n**** Starting to read from pipe ****\n')
done = false;

num_again = 0;
errno(0);
fclear(out);
while(1)
  if (ispc() && ~isunix())
    %% reset errno before the syscall, harmful on Linux?
    % what about Mac OS X?
    %errno(0);   % see octave syscall.cc test on windows
  end
  s = fgets (out);
  if (ischar (s))
    disp('<out>')
    fputs (stdout, s);
    disp('</out>')
  elseif (errno() == EINVAL)
    fclear (out);
    errno(0);   % reset errno, is this sufficient for win32?
    sleep (0.15);
    disp('waiting (on win32)')
    num_again++;
    assert (ispc() && ~isunix())
  elseif (errno() == EAGAIN)
    fclear(out);
    errno(0);   % not required on posix but harmless?
    sleep(0.15);
    disp('waiting (on posix)')
    num_again++;
    %assert (~ispc() && isunix())
  else
    warning(sprintf('fgets returned non-string, unexpected errno: s=%d, errno=%d', s, errno()))
    sleep(0.1);
    num_again++;
  end
  if (num_again > 25)
    disp('25 waits, breaking out')
    break
  end
end

if (~close_first)
  r = fclose (in);  assert(r == 0)
end
r = fclose (out);  assert(r == 0)
[pid,st,msg] = waitpid (pid)
