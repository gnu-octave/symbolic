%% Copyright (C) 2014, 2016 Colin B. Macdonald
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
%% @documentencoding UTF-8
%% @defmethod  @@sym cat (@var{dim}, @var{A}, @var{B}, @dots{})
%% Concatenate symbolic arrays along particular dimension.
%%
%% @var{dim} is currently restricted to 1 or 2 as symbolic arrays
%% are currently only two-dimensional.
%%
%% Example:
%% @example
%% @group
%% syms x
%% cat(1, x, 2*x, 3*x)
%%   @result{} (sym) [x  2⋅x  3⋅x] (1×3 matrix)
%% cat(2, x, x)
%%   @result{} (sym 2×1 matrix)
%%       ⎡x⎤
%%       ⎢ ⎥
%%       ⎣x⎦
%% @end group
%% @end example
%% @seealso{@@sym/vertcat, @@sym/horzcat}
%% @end defmethod

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function z = cat(dim, varargin)

  if (logical(dim == 1))
    z = horzcat(varargin{:});
  elseif (logical(dim == 2))
    z = vertcat(varargin{:});
  else
    print_usage ();
  end

end


%!test
%! % mostly tested in horzcat, vertcat: one for good measure
%! syms x
%! assert (isequal (cat(1, x, x), [x x]))
%! assert (isequal (cat(2, x, x), [x; x]))

%!error cat(3, sym(2), sym(3))
%!error cat(0, sym(2), sym(3))
