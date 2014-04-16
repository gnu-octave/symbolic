addpath(pwd)
base = 'unittests';
files = dir(base);
cd(base);

% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = time();
totalcputime = cputime();
num_tests = 0;
num_failed = 0;
for i=1:length(files)
  mfile = files(i).name;
  % detect tests b/c directory contains other stuff (e.g., surdirs and
  % helper files)
  if ( (~files(i).isdir) && strncmp(mfile, 'test', 4) && mfile(end) ~= '~')
    testtime = time();
    str = mfile(1:end-2);
    f = str2func(str);
    num_tests = num_tests + 1;
    disp(['** Running test(s) in: ' mfile ]);
    pass = f();
    testtime = time() - testtime;
    if all(pass)
      fprintf('** PASS: %s  [%g sec]\n', str, testtime);
    else
      fprintf('** FAIL: %s  [%g sec]\n', str, testtime);
      num_failed = num_failed + 1;
      pass
    end
  end
end

totaltime = time() - totaltime;
totalcputime = cputime() - totalcputime;
fprintf('\n***** Passed %d/%d tests passed, %g seconds (%gs CPU) *****\n', ...
        num_tests-num_failed, num_tests, totaltime, totalcputime);
if (num_failed > 0)
  disp('***** WARNING: some tests failed *****');
end
cd('..')
