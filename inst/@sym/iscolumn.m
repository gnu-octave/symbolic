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
%% @defmethod @@sym iscolumn (@var{x})
%% Return true if symbolic expression is a column vector.
%%
%% Example:
%% @example
%% @group
%% v = sym([1; 2; 3]);
%% iscolumn(v)
%%   @result{} 1
%% iscolumn(sym(1))
%%   @result{} 1
%% iscolumn(v')
%%   @result{} 0
%% @end group
%% @end example
%%
%% @seealso{@@sym/isrow, @@sym/isvector, @@sym/isscalar}
%% @end defmethod


function r = iscolumn(x)

  if (nargin ~= 1)
    print_usage ();
  end

  % from Rik Wehbring's Octave function:
  sz = size (x);
  r = (ndims (x) == 2 && (sz(2) == 1));

end


%!assert (iscolumn (sym ([1])))
%!assert (iscolumn (sym ([1 2 3]')))
%!assert (~iscolumn (sym ([])))
%!assert (~iscolumn (sym ([1 2 3])))
%!assert (~iscolumn (sym ([1 2; 3 4])))
