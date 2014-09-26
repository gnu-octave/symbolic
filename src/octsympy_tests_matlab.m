addpath(pwd)
base = 'tests_matlab';
files = dir(base);
cd(base);

% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = clock();
totalcputime = cputime();
num_tests = 0;
% do tests in random order:
%rng('shuffle')
%for i=randperm(length(files))
for i=1:length(files)
  mfile = files(i).name;
  % detect tests b/c directory contains other stuff (e.g., surdirs and
  % helper files)
  if ( (~files(i).isdir) && strncmp(mfile, 'test', 4) && mfile(end) ~= '~')
    testtime = clock();
    str = mfile(1:end-2);
    num_tests = num_tests + 1;
    disp(['>>> Running test(s) in: ' mfile ]);
    eval(str)
    testtime = etime(clock(), testtime);
  end
end

totaltime = etime(clock(),totaltime);
totalcputime = cputime() - totalcputime;
fprintf('\n***** Ran tests from %d files, %g seconds (%gs CPU) *****\n', ...
        num_tests, totaltime, totalcputime);
cd('..')
