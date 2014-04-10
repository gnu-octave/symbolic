function r = end (obj, index_pos, num_indices)

  if ~(isscalar(index_pos))
    error('can this happen?')
  end

  if (num_indices == 1)
    % todo enable after numel change
    %r = numel(obj)
    r = prod(size(obj));
  elseif (num_indices == 2)
    d = size(obj);
    r = d(index_pos);
  else
    obj
    index_pos
    num_indices
    error('now whut?');
  end
