methods_list = methods(sym);
base = '@sym';

% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = clock();
totalcputime = cputime();

num_tests = 0;
num_passed = 0;
for i=1:length(methods_list)
  m = methods_list{i};
  fprintf('**** Looking for tests in: %s\n', m);
  [N,MAX] = test([base '/' m]); %, 'quiet');
  num_tests = num_tests + MAX;
  num_passed = num_passed + N;
  % this doesn't really work, bug in Octave?  MAX,N always zero
  % if failures.  https://savannah.gnu.org/bugs/?42150
  if (MAX > 0)
    fprintf('**** %s Passed %d of %d\n', m, N, MAX);
    fprintf('%s\n\n', char('_'*ones(1,80)));
    %fprintf('  (paused)\n'); pause
  end
end

totaltime = etime(clock(), totaltime);
totalcputime = cputime() - totalcputime;
fprintf('\n***** Passed %d/%d tests passed, %g seconds (%gs CPU) *****\n', ...
        num_passed, num_tests, totaltime, totalcputime);
if (num_tests - num_passed > 0)
  disp('***** WARNING: some tests failed *****');
end
