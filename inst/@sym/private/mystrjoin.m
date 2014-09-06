function s = mystrjoin(A, sepchar)
% replacement for strjoin until Octave 3.6 is old

  persistent have_strjoin

  if isempty(have_strjoin)
    % this test is slow if it does not exist (6s for 1000 calls)
    % (28s w/, 24 w/o) so we cache the result
    if (exist('strjoin') > 1)
      have_strjoin = true;
    else
      have_strjoin = false;
    end
  end

  if (have_strjoin)
    s = strjoin(A, sepchar);
    return
  end

  %% we have no strjoin, do our own
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

  %try
  %  s = strjoin(A, sepchar);
  %catch
  %  [msg, msgid] = lasterr ();
  %  if ~strncmp(msg, '''strjoin'' undefined', 19)
  %    error(msgid, msg)
  %  end
  %end

  % for loop above is 23s

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

