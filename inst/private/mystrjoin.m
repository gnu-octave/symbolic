function s = mystrjoin(A, sepchar)
% replacement for strjoin until Octave 3.6 is old

  persistent have_strjoin

  % 28s w/, 24 w/o
  % if we have it, use it, unfortunately this test is slow
  if exist('strjoin', 'builtin');  % or file FIXME: check 3.8
    s = strjoin(A, sepchar);
    return
  end

  if (1==0)
  try
    s = strjoin(A, sepchar);

  catch
    [msg, msgid] = lasterr ();
    if ~strncmp(msg, '''strjoin'' undefined', 19)
      error(msgid, msg)
    end
    %% we have mo strjoin, do our own
    n = numel(A);

    if (n == 0)
      s = '';
    else
      s = A{1};
    end

    for i = 2:n
      s = [s sepchar A{i}];
    end
  end


  else


  % 23s if delete exists test
  n = numel(A);

  if n == 0
    s = '';
  else
    s = A{1};
  end

  for i = 2:n
    s = [s sepchar A{i}];
  end

  % 23s
  %L(2,:) = repmat({newl}, 1, length(L));
  %fputs(f, [L{:}]);

  % 27s
  %B = cellfun(@(x) fputs(f, [x newl]), L);

  % 27s
  %B = cellfun(@(x) [x newl], L, 'UniformOutput', false);
  %fputs (f, [B{:}]);

  % 30s
  %B = cellfun(@(x) [x newl], L, 'UniformOutput', false);
  %B = cellfun(@(x) fputs(f, x), B);

  % 24 s
  %for i = 1:length(L)
  %  fputs (f, L{i});
  % fputs (f, newl);
  %end
  end

end


