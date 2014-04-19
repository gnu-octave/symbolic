function z = mat_access(A, subs)
%MAT_ACCESS  private helper routine
%   Big piece of spaghetti code :(

  if ((length(subs) == 1) && (islogical(subs{1})))
    %% A(logical)
    z = mat_mask_access(A, subs{1});
    return

  elseif ( (length(subs) == 1) && strcmp(subs{1}, ':') )
    %% A(:)
    z = reshape(A, numel(A), 1);
    return

  elseif ((length(subs) == 1) && (~isvector(A)))
    %% linear index into a matrix A
    i = subs{1};
    if (isempty(i))
      z = sym([]);
      return
    end
    if (~isvector(i) || ischar(i))
      size(i), i
      error('what?');
    end
    [r, c] = ind2sub (size(A), i);
    z = mat_rclist_access(A, r, c);
    return

  elseif ((length(subs) == 1) && (isvector(A)))
    %% linear index into a vector A
    i = subs{1};
    if (isempty(i))
      z = sym([]);
      return
    end
    if (~isvector(i) || ischar(i))
      size(i), i
      error('what?');
    end
    [r, c] = ind2sub (size(A), i);
    z = mat_rclist_access(A, r, c);
    % output shape, see logic in comments in mat_mask_access.m
    if (isrow(A))
      z = reshape(z, 1, length(c));
    elseif (iscolumn(A))
      assert(iscolumn(z))
    else
      error('Tertium Non Datur')
    end
    return

  elseif (length(subs) == 2)
    r = subs{1};
    c = subs{2};
    assert( isvector(r) || isempty(r) || strcmp(r, ':') )
    assert( isvector(c) || isempty(c) || strcmp(c, ':') )
    z = mat_rccross_access(A, r, c);
    return

  else
    error('Unknown indexing')
  end

end
