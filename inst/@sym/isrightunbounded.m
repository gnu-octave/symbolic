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
%% @defmethod @@sym isrightunbounded (@var{x})
%% Return True if the right endpoint is positive infinity.
%%
%% Example:
%% @example
%% @group
%% a = interval (0, sym (inf));
%% isrightunbounded (a)
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @group
%% a = interval (-inf, sym (0));
%% isrightunbounded (a)
%%   @result{} ans = (sym) True
%% @end group
%% @end example
%%
%% @end defmethod


function y = isrightunbounded(x)
  if (nargin ~= 1)
    print_usage ();
  end
  y = elementwise_op ('lambda x: x.is_right_unbounded', sym (x));
end


%!test
%! a = interval (sym (-inf), 1);
%! assert (logical (~isrightunbounded (a)))

%!test
%! a = interval (sym (0), inf);
%! assert (logical (isrightunbounded (a)))
