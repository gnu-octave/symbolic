%% Copyright (C) 2014 Colin B. Macdonald
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
%% @deftypefn  {Function File} {@var{z} =} mat_replace (@var{A}, @var{subs}, @var{rhs})
%% Private helper routine for setting symbolic array entries.
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mat_replace(A, subs, b)

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
    if ~( isscalar(b) || is_same_shape (r, b) )
      % Octave/Matlab both do this for double so we will to
      error('A(I,J,...) = X: dimensions mismatch')
    end
    r = r(:);
    c = c(:);
  else
    error('unknown indexing')
  end

  z = mat_rclist_asgn(A, r, c, b);

end
