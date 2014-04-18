base = '@sym';
files = dir(base);

% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = clock();
totalcputime = cputime();

num_tests = 0;
num_passed = 0;
for i=1:length(files)
  mfile = files(i).name;
  if ( (~files(i).isdir) && strcmp(mfile(end-1:end), '.m') )
    str = mfile(1:end-2);
    fprintf('**** Looking for tests in: %s\n', mfile);
    [N,MAX] = test([base '/' str]); %, 'quiet');
    num_tests = num_tests + MAX;
    num_passed = num_passed + N;
    if (MAX > 0)
      fprintf('**** %s Passed %d of %d\n', mfile, N, MAX);
      fprintf('%s\n\n', char('_'*ones(1,80)));
      %fprintf('  (paused)\n'); pause
    end
  end
end

totaltime = etime(clock(), totaltime);
totalcputime = cputime() - totalcputime;
fprintf('\n***** Passed %d/%d tests passed, %g seconds (%gs CPU) *****\n', ...
        num_passed, num_tests, totaltime, totalcputime);
if (num_tests - num_passed > 0)
  disp('***** WARNING: some tests failed *****');
end
