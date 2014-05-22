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
    if (isscalar(A) && (i == 1))
      z = A;
      return
    end
    if (~isvector(i) || ischar(i))
      size(i), i
      error('what?');
    end
    [r, c] = ind2sub (size(A), i);
    z = mat_rclist_access(A, r, c);
    % output shape, see logic in comments in mat_mask_access.m
    if (my_isrow(A))
      z = reshape(z, 1, length(c));
    elseif (my_iscolumn(A))
      assert(my_iscolumn(z))
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
