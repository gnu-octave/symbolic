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
%% @defmethod @@sym complement (@var{x}, @var{y})
%% The complement of @var{x} with @var{y} as Universe.
%%
%% Example:
%% @example
%% @group
%% a = interval (sym (0), 10);
%% b = interval (sym (4), 6);
%% a - b
%%   @result{} ans = (sym) [0, 4) ∪ (6, 10]
%% @end group
%% @end example
%% @example
%% @group
%% complement (b, a)
%%   @result{} ans = (sym) [0, 4) ∪ (6, 10]
%% @end group
%% @end example
%%
%% @end defmethod


function y = complement(x, y)
  if (nargin ~= 2)
    print_usage ();
  end
  y = elementwise_op ('lambda x, y: x.complement(y)', sym (x), sym (y));
end


%!test
%! R = domain ('Reals');
%! a = interval (sym (-1), 1);
%! b = interval (sym (-inf), -1, true, true) + interval (sym (1), inf, true, true);
%! assert (isequal (complement (a, R), b))
