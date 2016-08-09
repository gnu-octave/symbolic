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
%% @defmethod @@sym isscalar (@var{x})
%% Return true if this symbolic expression is a scalar.
%%
%% Example:
%% @example
%% @group
%% s = sym(1);
%% v = sym([1 2 3]);
%% isscalar(s)
%%   @result{} 1
%% isscalar(v)
%%   @result{} 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/size, @@sym/numel, @@sym/isvector}
%% @end defmethod


function b = isscalar(x)

  if (nargin ~= 1)
    print_usage ();
  end

  d = size(x);
  n = prod(d);
  b = (n == 1);

end


%!assert(isscalar(sym('x')))

%!test
%! a = sym([1 2 3]);
%! assert(~isscalar(a))

%!assert(~isscalar(sym([])))
