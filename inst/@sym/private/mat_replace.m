%% Copyright (C) 2014-2016, 2019 Colin B. Macdonald
%% Copyright (C) 2016 Lagu
%% Copyright (C) 2016 Abhinav Tripathi
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

%% Author: Colin B. Macdonald
%% Keywords: symbolic

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
            z = pycall_sympy__ ('_ins[0].col_del(_ins[1] - 1); return _ins[0],', A, sym(subs{1}));
            return
          elseif columns(A) == 1
            z = pycall_sympy__ ('_ins[0].row_del(_ins[1] - 1); return _ins[0],', A, sym(subs{1}));
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
          z = pycall_sympy__ ('_ins[0].col_del(_ins[1] - 1); return _ins[0],', A, sym(subs{2}));
          return
        elseif strcmp(subs{2}, ':')
          z = pycall_sympy__ ('_ins[0].row_del(_ins[1] - 1); return _ins[0],', A, sym(subs{1}));
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
      [r, c] = ind2sub (size(A), subs{1});
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
