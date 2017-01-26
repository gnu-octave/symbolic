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
%% @defmethod @@sym isintersection (@var{x})
%% Return True if @var{x} is intersection.
%%
%% Example:
%% @example
%% @group
%% syms x
%% a = interval (x, 1);
%% b = interval (sym (-1), 3);
%% isintersection (intersect (a, b))
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @end defmethod


function y = isintersection(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.is_Intersection', sym (x));
end


%!test
%! syms x
%! a = interval(sym(0), x^2);
%! b = interval(x, 1);
%! c = isintersection (intersect (a, b));
%! if isa(c, 'sym')
%!   assert (~isNone (c))
%! else
%!   assert (logical (c));
%! end

%!test
%! a = interval (sym (0), 4);
%! b = interval (2, sym (8));
%! c = isintersection (intersect (a, b));
%! if isa (c, 'sym')
%!   assert (isNone (c))
%! else
%!   assert (~logical (c));
%! end
