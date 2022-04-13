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
%% @defmethod @@sym isdisjoint (@var{x}, @var{y})
%% Returns True if @var{x} and @var{y} are disjoint.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (0), 10);
%% b = interval (sym (11), 15);
%% isdisjoint (a, b)
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @end defmethod


function y = isdisjoint(x, y)
  if (nargin ~= 2)
    print_usage ();
  end
  y = elementwise_op ('lambda x, y: x.is_disjoint(y)', sym (x), sym (y));
end


%!test
%! a = interval (sym (0), 2);
%! b = interval (sym (1), 2);
%! assert (logical (~isdisjoint (a, b)))

%!test
%! a = interval (sym (0), 2);
%! b = interval (sym (3), 4);
%! assert (logical (isdisjoint (a, b)))
