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
%% @deftypefn  {Function File} {@var{z} =} mat_access (@var{A}, @var{subs})
%% Private helper routine for symbolic array access.
%%
%% Big piece of spaghetti code :(
%%
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = mat_access(A, subs)

  if ((length(subs) == 1) && (islogical(subs{1})))
    %% A(logical)
    z = mat_mask_access(A, subs{1});
    return

  elseif ( (length(subs) == 1) && strcmp(subs{1}, ':') )
    %% A(:)
    z = reshape(A, numel(A), 1);
    return

  elseif (length(subs) == 1)
    %% linear index into a matrix/vector/scalar A
    i = subs{1};
    if (isempty(i))
      z = sym([]);
      return
    end
    if (ischar(i))
      error(['invalid indexing, i="' i '"'])
    end
    [r, c] = ind2sub (size(A), i);
    z = mat_rclist_access(A, r(:), c(:));
    % output shape, see also logic in comments in mat_mask_access.m
    if (~isscalar(A) && my_isrow(A) && isvector(i))
      z = reshape(z, 1, length(i));  % i might be row or col
    elseif (~isscalar(A) && my_iscolumn(A) && isvector(i))
      assert(my_iscolumn(z))
    else
      % all other cases we take shape of i
      z = reshape(z, size(i));
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
