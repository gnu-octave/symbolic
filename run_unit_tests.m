addpath(pwd)
tests = dir('unittests');
cd('unittests');

totaltime = cputime();
num_tests = 0;
num_failed = 0;
for i=1:length(tests)
  test = tests(i).name;
  % detect tests b/c directory contains other stuff (e.g., surdirs and
  % helper files)
  if ( (~tests(i).isdir) && strncmp(test, 'test', 4) )
    testtime = cputime();
    f = str2func(test(1:end-2));
    num_tests = num_tests + 1;
    disp(['** Running test(s) in: ' test ]);
    %[pass,str] = f();
    pass = f(); str = 'dummy';
    testtime = cputime() - testtime;
    if all(pass)
      fprintf('** PASS: %s  [%g sec]\n', str, testtime);
    else
      fprintf('** FAIL: %s  [%g sec]\n', str, testtime);
      num_failed = num_failed + 1;
      pass
    end
  end
end

totaltime = cputime() - totaltime;
fprintf('\n***** Passed %d/%d tests passed (%g seconds) *****\n', ...
        num_tests-num_failed, num_tests, totaltime);
if (num_failed > 0)
  disp('***** WARNING: some tests failed *****');
end
cd('..')
