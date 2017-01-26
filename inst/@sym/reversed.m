%% Copyright (C) 2017 Lagu
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
%% @defmethod @@sym reversed (@var{x})
%% Return an @var{x} Range in the opposite order.
%%
%% Example:
%% @example
%% @group
%% a = rangeset (sym (0), 10, 3);
%% reversed (a)         % doctest: +SKIP
%%   @result{} ans = (sym) @{9, 6, 3, 0@}
%% @end group
%% @end example
%%
%% @end defmethod


function y = reversed(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.reversed', sym (x));
end


%!test
%! if (python_cmd ('return Version(spver) > Version("1.0")'))
%!   a = rangeset (sym (10), 1, -3);
%!   b = reversed (reversed (a));
%!   assert (isequal (a, b))
%! end
