function A = write_lines(f, L, xtra)
%private function

  newl = sprintf('\n');

  if (xtra)
    L(end+1:end+2) = {'' ''};
  end

  fputs(f, strjoin(L, newl));

end

