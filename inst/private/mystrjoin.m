function s = mystrjoin(A, sepchar)
% replacement for strjoin until Octave 3.6 is old

  % if we have it, use it
  if exist('strjoin', 'builtin');  % or file FIXME: check 3.8
    s = strjoin(A, sepchar);
    return
  end

  n = numel(A);

  if n == 0
    s = '';
  else
    s = A{1};
  end

  for i = 2:n
    s = [s sepchar A{i}];
  end
end


