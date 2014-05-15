
% usually I'd just use cputime(), but some of our IPC mechanisms are
% light on CPU and heavy on IO.
totaltime = clock();
totalcputime = cputime();

num_tests = 0;
num_passed = 0;

classes = {'sym', 'symfun'};

for j = 1:length(classes)
  methods_list = methods(classes{j});
  base = ['@' classes{j}];

for i=1:length(methods_list)
  m = methods_list{i};
  %fprintf('>>>>> Looking for tests in: %s/%s\n', classes{j}, m);
  % Must use this calling mode, https://savannah.gnu.org/bugs/?42150
  [N,MAX] = test([base '/' m], [], stdout);
  num_tests = num_tests + MAX;
  num_passed = num_passed + N;
  if (MAX > 0)
    fprintf('>>>>>   Passed %d of %d\n', N, MAX);
    %fprintf('%s\n\n', char('_'*ones(1,80)));
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
