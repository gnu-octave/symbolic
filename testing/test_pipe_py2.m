more off

EAGAIN = errno ('EAGAIN')
EINVAL = errno ('EINVAL')

disp('** calling popen2')

%[in, out, pid] = popen2 ('python', '-i')
%[in, out, pid] = popen2 ('n:\win32\py275.exe')
%[in, out, pid] = popen2 ('py.exe', {'-S'})  % ok
%[in, out, pid] = popen2 ('py.exe', {'-S'})
%[in, out, pid] = popen2 ('py.exe', {'-i' '--help'})
%[in, out, pid] = popen2 ('busybox.exe', {'cat'})
%[in, out, pid] = popen2 ('myecho.bat')
[in, out, pid] = popen2 ('winwrapy.bat')


%[in, out, pid] = popen2 ('C:\Windows\system32\sort.exe', '/R')
%[in, out, pid] = popen2 ('sort', '/R')
%[in, out, pid] = popen2 ('cat')
assert(pid > 0)

if (ispc() && ~isunix())
  %newl = sprintf('\r\n');
  newl = sprintf('\n');
else
  newl = sprintf('\n');
end
r = fputs (in, ['a = 42; print((a,a,a))' newl newl]);
assert(r == 0)

r = fputs (in, ['a = "colin"; print(a)' newl newl]);
assert(r == 0)

r = fputs (in, ['a = 43; print((a,a,a))' newl newl]);
assert(r == 0)

% works
%r = fputs (in, sprintf('a = "macdonald"; print(a)\n\n'))
r = fputs (in, 'a = "macdonald"; print(a)');
assert(r == 0)

r = fputs (in, [newl newl]);
assert(r == 0)

r = fputs (in, ['import time' newl newl]); assert(r == 0)
r = fputs (in, ['time.sleep(1.5)' newl newl]); assert(r == 0)

r = fputs (in, ['import sys' newl newl]); assert(r == 0)
r = fputs (in, ['print(sys.version_info)' newl newl]); assert(r == 0)

sleep(1)
r = fputs (in, ['a = 44; print((a,a,a))' newl newl]);
assert(r == 0)
%r = fputs (in, '\n\n')

r = fflush(in);
assert(r == 0)

%r = fputs (in, ["zese" newl "are" newl "some" newl "strings" newl])
%assert(r == 0)

r = fflush(in);
assert(r == 0)

fclear (in);
%r = fclose (in);  assert(r == 0)

sleep (0.1);

disp('** reading it back')
done = false;

num_again = 0;
do
  %errno(0);   % see syscall.cc test on windows
  s = fgets (out);
  if (ischar (s))
    fputs (stdout, s);
  elseif (errno () == EINVAL)
    disp(sprintf('waiting (win32), s=%d, errno=%d', s, errno()))
    errno(0);
    fclear (out);
    %fclear (in);
    %fputs (in, newl);
    sleep (0.2);
    num_again++;
    if (num_again > 30)
       disp('no many waits, breaking out')
       break
    end
  elseif (errno () == EAGAIN)
    errno
    fclear (out);
    sleep (0.2);
    disp('waiting (on posix)')
  else
    disp(sprintf('waiting (somewhere), s=%d, errno=%d', s, errno()))
    sleep (0.2);
    num_again++;
    if (num_again > 12)
       disp('no many waits, breaking out')
       break
    end
    %done = true;
  end
until (done)

r = fclose (in);  assert(r == 0)
fclose (out);
waitpid (pid);

