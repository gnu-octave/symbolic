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
%% @defmethod @@sym ainterval (@var{x})
%% Return the union of intervals of x when, @var{x} is in rectangular form
%% or the union of intervals of r when self is in polar form.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (2), 3);
%% b = interval (sym (4), 5);
%% ainterval (complexregion (a * b))
%%   @result{} ans = (sym) [2, 3]
%% @end group
%% @end example
%%
%% @example
%% @group
%% c = interval (sym (1), 7);
%% ainterval (complexregion (a * b + b * c))
%%   @result{} ans = (sym) [2, 3] ∪ [4, 5]
%% @end group
%% @end example
%%
%% @end defmethod


function y = ainterval(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.a_interval', sym (x));
end


%!test
%! a = interval (sym (1), 2);
%! b = interval (sym (4), 5);
%! k = ainterval (complexregion (a * b));
%! assert (isequal (k, a))

%!test
%! a = interval (sym (1), 2);
%! b = interval (sym (4), 5);
%! c = interval (sym (-3), 2);
%! k = ainterval (complexregion (a * b + b * c));
%! assert (isequal (k, a + b))
