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
%% @defmethod @@sym isleftunbounded (@var{x})
%% Return True if the left endpoint is negative infinity.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (-inf), 0);
%% isleftunbounded (a)
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @example
%% @group
%% a = interval (sym (0), inf);
%% isleftunbounded (a)
%%   @result{} ans = (sym) False
%% @end group
%% @end example
%%
%% @end defmethod


function y = isleftunbounded(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.is_left_unbounded', sym (x));
end


%!test
%! a = interval (sym (-inf), 1);
%! assert (logical (isleftunbounded (a)))

%!test
%! a = interval (sym (0), inf);
%! assert (logical (~isleftunbounded (a)))
