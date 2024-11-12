%% Copyright (C) 2014-2016, 2019, 2022-2023 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016 Abhinav Tripathi
%% Copyright (C) 2017 NVS Abhilash
%% Copyright (C) 2020 Fernando Alvarruiz
%% Copyright (C) 2022 Alex Vong
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @defun mat_replace (@var{A}, @var{subs}, @var{rhs})
%% Private helper routine for setting symbolic array entries.
%%
%% @end defun


function z = mat_replace(A, subs, b)

  if (length (subs) == 1 && islogical (subs{1}))
    %% A(logical) = B
    subs{1} = find (subs{1});
    if isempty (subs{1})
      z = A;
      return;
    end
  end
  %% Check when b is []
  if (isempty(b))
    switch length(subs)
      case 1
        if strcmp(subs{1}, ':')
          z = sym([]);
          return
        end
        if (isempty (subs{1}))
          z = A;
          return
        end
          if rows(A) == 1
            z = delete_col(A, subs{1});
            return
          elseif columns(A) == 1
            z = delete_row(A, subs{1});
            return
          else
            z = sym([]);
            for i=1:A.size(2)
              z = [z subsref(A, substruct ('()', {':', i})).'];
            end
            z = subsasgn (z, substruct ('()', {subs{1}}), []);
            return
          end
      case 2
        if (isempty (subs{1}) || isempty (subs{2}))
          z = A;
          return
        end
        if strcmp(subs{1}, ':')
          if strcmp(subs{2}, ':')
            z = sym(zeros(0,columns(A)));
            return
          else
            z = delete_col(A, subs{2});
            return
          end
        elseif strcmp(subs{2}, ':')
          z = delete_row(A, subs{1});
          return
        else
          error('A null assignment can only have one non-colon index.'); % Standard octave error
        end
      otherwise
        error('Unexpected subs input')
    end
  end

  if (length(subs) == 1 && strcmp(subs{1}, ':') && length(b) == 1)
    z = pycall_sympy__ ('return ones(_ins[0], _ins[1])*_ins[2],', uint64(A.size(1)), uint64(A.size(2)), sym(b));
    return

  elseif (length(subs) == 1)
    % can use a single index to grow a vector, so we carefully deal with
    % vector vs linear index to matrix (not required for access)
    [n,m] = size(A);
    if (n == 0 || n == 1)
      c = subs{1};  r = ones(size(c));
    elseif (m == 1)
      r = subs{1};  c = ones(size(r));
    else
      % linear indices into 2D array
      % Octave 8 does not raise error from ind2sub so we do it ourselves
      sz = size (A);
      i = subs{1};
      if (i > prod (sz))
        error ('%d is out of bound %d (dimensions are %dx%d)\n', i, prod (sz), sz)
      end
      [r, c] = ind2sub (size (A), i);
      % keep all the indices in a row vector
      r = reshape (r, 1, []);
      c = reshape (c, 1, []);
    end

  elseif (length(subs) == 2)
    r = subs{1};
    c = subs{2};
    [n,m] = size(A);

    if (isnumeric(r) && ((isvector(r) || isempty(r))))
      % no-op
    elseif (strcmp(r,':'))
      r = 1:n;
    elseif (islogical(r) && isvector(r) && (length(r) == n))
      I = r;
      r = 1:n;  r = r(I);
    else
      error('unknown 2d-indexing in rows')
    end

    if (isnumeric(c) && ((isvector(c) || isempty(c))))
      % no-op
    elseif (strcmp(c,':'))
      c = 1:m;
    elseif (islogical(c) && isvector(c) && (length(c) == m))
      J = c;
      c = 1:m;  c = c(J);
    else
      error('unknown 2d-indexing in columns')
    end

    [r,c] = ndgrid(r,c);
    if ~(isscalar (b) || (isvector (r) && isvector (b)) || is_same_shape (r, b))
      % vectors may have diff orientations but if we have matrices then
      % they must have the same shape (Octave/Matlab do this for double)
      error('A(I,J,...) = X: dimensions mismatch')
    end
    r = r(:);
    c = c(:);
  else
    error('unknown indexing')
  end

  z = mat_rclist_asgn(A, r, c, b);

end


function z = delete_col(A, subs)
  if isscalar (A)
    z = sym(zeros (1, 0));
  else
    cmd = { 'AA, subs = _ins'
            'A = AA.as_mutable()'
            'if isinstance(subs, Integer):'
            '    A.col_del(subs - 1)'
            '    return A,'
            'for i in sorted(subs, reverse=True):'
            '    A.col_del(i - 1)'
            'return A,' };
    z = pycall_sympy__ (cmd, A, sym(subs));
  end
end


function z = delete_row(A, subs)
  if isscalar (A)
    % no test coverage: not sure how to hit this
    z = sym(zeros (0, 1));
  else
    cmd = { 'AA, subs = _ins'
            'A = AA.as_mutable()'
            'if isinstance(subs, Integer):'
            '    A.row_del(subs - 1)'
            '    return A,'
            'for i in sorted(subs, reverse=True):'
            '    A.row_del(i - 1)'
            'return A,' };
    z = pycall_sympy__ (cmd, A, sym(subs));
  end
end
