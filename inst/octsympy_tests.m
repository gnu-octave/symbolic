% count = 1
dirs = {'.' '@symfun' '@logical' '@sym'};

if ~exist('count') || count == 0

  for j = 1:length(dirs)
    runtests(fullfile(pwd, dirs{j}))
    fprintf('%s\n\n', char('_'*ones(1,80)));
  end

else

  %% Old version
  % keeping this code around b/c it can count the number of tests
  % passed for me...

  totaltime = clock();
  totalcputime = cputime();

  num_tests = 0;
  num_passed = 0;

  for j = 1:length(dirs)
    %methods_list = methods(classes{j});
    %base = ['@' classes{j}];
    thisdir = fullfile(pwd, dirs{j});
    files = dir(thisdir);

    %for i=1:length(methods_list)
    %m = methods_list{i};
    for i=1:length(files)
      m = files(i).name;
      if ( (~files(i).isdir) && strcmp(m(end-1:end), '.m') )
        [N,MAX] = test([dirs{j} '/' m], [], stdout);
        num_tests = num_tests + MAX;
        num_passed = num_passed + N;
        if (MAX > 0)
          fprintf('        Passed %d of %d\n', N, MAX);
          %fprintf('%s\n\n', char('_'*ones(1,80)));
          %fprintf('  (paused)\n'); pause
        end
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
end
