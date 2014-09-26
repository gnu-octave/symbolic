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
%% @deftypefn  {Function File} {@var{d} =} size (@var{x})
%% @deftypefnx {Function File} {[@var{n}, @var{m}] =} size (@var{x})
%% @deftypefnx {Function File} {@var{d} =} size (@var{x}, @var{dim})
%% Return the size of a symbolic array.
%%
%% @seealso{length, numel}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [n, m] = size(x, dim)

  n = x.size;
  if (nargin == 2) && (nargout == 2)
    error('size: invalid call')
  elseif (nargout == 2)
    m = n(2);
    n = n(1);
  elseif (nargin == 2)
    n = n(dim);
  end

end


%!test
%! a = sym([1 2 3]);
%! [n,m] = size(a);
%! assert (n == 1 && m == 3)

%!test
%! a = sym([1 2 3]);
%! n = size(a);
%! assert (isequal (n, [1 3]))

%!test
%! %% size, numel, length
%! a = sym([1 2 3; 4 5 6]);
%! assert (isa (size(a), 'double'))
%! assert (isa (numel(a), 'double'))
%! assert (isa (length(a), 'double'))
%! assert (isequal (size(a), [2 3]))
%! assert (length(a) == 3)
%! assert (numel(a) == 6)
%! a = sym([1; 2; 3]);
%! assert (isequal (size(a), [3 1]))
%! assert (length(a) == 3)
%! assert (numel(a) == 3)

%!test
%! %% size by dim
%! a = sym([1 2 3; 4 5 6]);
%! n = size(a, 1);
%! assert (n == 2)
%! m = size(a, 2);
%! assert (m == 3)
%! a = sym([1 2 3]');
%! n = size(a, 1);
%! assert (n == 3)
%! m = size(a, 2);
%! assert (m == 1)
