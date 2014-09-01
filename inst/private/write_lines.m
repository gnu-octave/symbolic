function A = write_lines(f, L, xtra)
%private function

  newl = sprintf('\n');

  if (xtra)
    L(end+1:end+2) = {'' ''};
  end

  % 23s
  L(2,:) = repmat({newl}, 1, length(L));
  fputs(f, [L{:}]);

  % 27s
  %B = cellfun(@(x) fputs(f, [x newl]), L);

  % 27s
  %B = cellfun(@(x) [x newl], L, 'UniformOutput', false);
  %fputs (f, [B{:}]);

  % 30s
  %B = cellfun(@(x) [x newl], L, 'UniformOutput', false);
  %B = cellfun(@(x) fputs(f, x), B);

  % 24 s
  for i = 1:length(L)
    fputs (f, L{i});
    fputs (f, newl);
  end

end

