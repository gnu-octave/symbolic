function z = mat_replace(A, subs, b)
%MAT_REPLACE  private helper routine

  if ( (length(subs) == 1) && (islogical(subs{1})) )
    %% A(logical) = B
    z = mat_mask_asgn(A, subs{1}, b);
    return

  elseif (length(subs) == 1)
    % can use a single index to grow a vector, so we carefully deal with
    % vector vs linear index to matrix (not required for access)
    [n,m] = size(A);
    if (n == 0 || n == 1)
      c = subs{1};  r = ones(size(c));
    elseif (m == 1)
      r = subs{1};  c = one(size(r));
    else
      % linear indices into 2D array
      [r, c] = ind2sub (size(A), subs{1});
    end

  elseif (length(subs) == 2)
    r = subs{1};
    c = subs{2};
    assert( isvector(r) || isempty(r) || strcmp(r, ':') )
    assert( isvector(c) || isempty(c) || strcmp(c, ':') )
    [n,m] = size(A);
    if (r == ':')
      r = 1:n;
    end
    if (c == ':')
      c = 1:m;
    end
    [r,c] = ndgrid(r,c);
    if ~ (is_same_shape (r, b))
      % Octave/Matlab both do this for double so we will to
      error('A(I,J,...) = X: dimensions mismatch')
    end
    r = r(:);
    c = c(:);
  else
    error('unknown indexing')
  end

  z = mat_rclist_asgn(A, r, c, b);

