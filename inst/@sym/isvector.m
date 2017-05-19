%% Copyright (C) 2014-2016 Colin B. Macdonald
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
%% @defmethod @@sym isvector (@var{x})
%% Return true if this symbolic expression is a vector.
%%
%% Example:
%% @example
%% @group
%% A = sym([1 2; 3 4]);
%% v = sym([1 2 3]);
%% h = v';
%% isvector(A)
%%   @result{} 0
%% isvector(v)
%%   @result{} 1
%% isvector(h)
%%   @result{} 1
%% @end group
%% @end example
%%
%% @seealso{@@sym/size, @@sym/numel, @@sym/isscalar}
%% @end defmethod


function b = isvector(x)

  if (nargin ~= 1)
    print_usage ();
  end

  d = size(x);
  b = any(d == 1);

end


%!assert(isvector(sym('x')))
%!assert(isvector(sym([1 2 3])))
%!assert(isvector(sym([1; 2])))
%!assert(~isvector(sym([1 2; 3 4])))
%!assert(~isvector(sym([])))
%!assert(isvector(sym(ones(1,0))))
%!assert(~isvector(sym(ones(0,3))))
