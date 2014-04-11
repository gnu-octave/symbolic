function s = cell_array_to_sym (L)
%private helper for sym ctor
%   convert a cell array to syms, recursively when nests cells found

  assert(iscell(L))

  s = cell(size(L));

  for i = 1:numel(L)
    %s{i} = sym(L{i});
    % not strictly necessary if sym calls this but maybe neater this way:
    item = L{i};
    if iscell(item)
      s{i} = cell_array_to_sym(item);
    else
      s{i} = sym(item);
    end
  end
