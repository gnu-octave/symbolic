function B = indent_lines(A, n)
% indent each line in the cell array A by n spaces

  pad = repmat(' ', 1, n);
  if (0 == 1)
    % 27s
    B = cellfun(@(x) [pad x], A, 'UniformOutput', false);
  else
    % 23s
    B = cell(size(A));
    for i = 1:numel(A)
      B{i} = [pad A{i}];
    end
  end
end
